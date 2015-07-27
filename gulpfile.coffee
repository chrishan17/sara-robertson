gulp = require 'gulp'
gutil = require 'gulp-util'

del = require 'del'
sass = require 'gulp-sass'
less = require 'gulp-less'
coffee = require 'gulp-coffee'
uglify = require 'gulp-uglify'
browserSync = require 'browser-sync'
autoprefixer = require 'gulp-autoprefixer'
browserify = require 'browserify'
gulpBrowserify = require 'gulp-browserify'
rename = require 'gulp-rename'
watchify = require 'watchify'
source = require 'vinyl-source-stream'
buffer = require 'vinyl-buffer'
sourcemaps = require 'gulp-sourcemaps'
glob = require 'glob'
_ = require 'lodash'

src =
    sass: './src/scss/**/*.scss'
    html: './index.html'
    coffee: './src/coffee/**/*.coffee'
    less: './src/less/**/*.less'

dest =
    css: './public/css/'
    html: './public/'
    js: './public/js/'

gulp.task 'browser-sync', ->
    files = [
        dest.css
        dest.html
        dest.js
    ]
    browserSync.init files,
        server:
          baseDir: "./public"
        watchOptions:
          debounceDelay: 1000

gulp.task 'html', ->
    gulp.src(src.html)
    .pipe(gulp.dest(dest.html))

gulp.task 'dev:scss', ->
    gulp.src(src.sass)
    .pipe(sass(errLogToConsole: true))
    .pipe(autoprefixer(browsers: ['last 2 version', 'safari 5', 'ie 8', 'ie 9', 'opera 12.1', 'ios 6', 'android 4']))
    .pipe(gulp.dest(dest.css))

gulp.task 'dev:less', ->
    gulp.src(src.less)
    .pipe(less())
    .pipe(autoprefixer(browsers: ['last 2 version', 'safari 5', 'ie 8', 'ie 9', 'opera 12.1', 'ios 6', 'android 4']))
    .pipe(gulp.dest(dest.css))

gulp.task 'dev:js', ->
    glob src.coffee, {}, (err, files) ->
        _.each files, (file) ->
            filename = file.split('/').pop()
            bundler = watchify browserify(file, watchify.args)
            bundler.on 'error', gutil.log.bind(gutil, 'Browserify Error')

            bundler.bundle()
            .pipe(source(filename))
            .pipe(buffer())
            .pipe(rename(extname: '.js'))
            .pipe(sourcemaps.init(loadMaps: true))
            .pipe(sourcemaps.write('./'))
            .pipe(gulp.dest(dest.js))


gulp.task 'watch', ->
    gulp.watch src.less, ['dev:less']
    gulp.watch src.coffee, ['dev:js']
    gulp.watch src.html, ['html']

    gulp.watch 'public/**/**', (file) ->
        if file.type is "changed"
            browserSync.reload(file.path)

gulp.task 'build:scss', ->
    gulp.src(src.sass)
    .pipe(sass(outputStyle: 'compressed'))
    .pipe(autoprefixer(browsers: ['last 2 version', 'safari 5', 'ie 8', 'ie 9', 'opera 12.1', 'ios 6', 'android 4']))
    .pipe(gulp.dest(dest.css))

gulp.task 'build:js', ->
    gulp.src(src.coffee, read: false)
    .pipe(gulpBrowserify(extensions: ['.coffee'], debug: false))
    .pipe(uglify())
    .pipe(rename(extname: '.js'))
    .pipe(gulp.dest(dest.js))

gulp.task 'clean', ->
    del(['public/css', 'public/js', 'public/index.html'])

gulp.task 'default', ['dev:less', 'dev:js', 'html', 'watch', 'browser-sync']

gulp.task 'build', ['build:scss', 'build:js']
