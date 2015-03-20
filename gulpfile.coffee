gulp = require 'gulp'
gutil = require 'gulp-util'

browserSync = require 'browser-sync'
sass = require 'gulp-sass'
autoprefixer = require 'gulp-autoprefixer'
coffeelint = require 'gulp-coffeelint'
coffee = require 'gulp-coffee'
uglify = require 'gulp-uglify'
notify = require 'gulp-notify'
del = require 'del'
runSequence = require 'run-sequence'

isProd = gutil.env.type is 'prod'

src =
    sass: 'src/scss/**/*.scss'
    html: 'index.html'
    coffee: 'src/coffee/**/*.coffee'

dest =
    css: 'public/css/'
    html: 'public/'
    js: 'public/js/'

gulp.task 'browser-sync', ->
    files = [
        dest.css
        dest.html
        dest.js
    ]
    browserSync.init files,
        server:
          baseDir: "./public"
        # watchOptions:
        #   debounceDelay: 1000

gulp.task 'html', ->
    gulp.src(src.html)
    .pipe(gulp.dest(dest.html))

gulp.task 'styles', ->
    gulp.src(src.sass)
    .pipe(sass(outputStyle: 'compressed', errLogToConsole: true))
    .pipe(autoprefixer(browsers: ['last 2 version', 'safari 5', 'ie 8', 'ie 9', 'opera 12.1', 'ios 6', 'android 4']))
    .pipe(gulp.dest(dest.css))
    # .pipe(notify(message: 'Styles task complete'))

gulp.task 'lint', ->
    gulp.src(src.coffee)
    .pipe(coffeelint())
    .pipe(coffeelint.reporter())

gulp.task 'scripts', ->
    gulp.src(src.coffee)
    .pipe(coffee(bare: true)).on('error', gutil.log)
    .pipe(if isProd then uglify() else gutil.noop())
    .pipe(gulp.dest(dest.js))
    # .pipe(notify(message: 'Scripts task complete'))

gulp.task 'watch', ->
    gulp.watch src.sass, ['styles']
    gulp.watch src.coffee, ['scripts']
    gulp.watch src.html, ['html']

    gulp.watch 'public/**/**', (file) ->
        console.log file
        browserSync.reload(file.path) if file.type is "changed"

gulp.task 'clean', ->
    del(['public/css', 'public/js', 'public/index.html'])

gulp.task 'build', ->
    runSequence 'clean', ['styles', 'scripts', 'html', 'lint']

gulp.task 'default', ->
    runSequence ['build', 'browser-sync', 'watch']
