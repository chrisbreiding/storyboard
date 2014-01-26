gulp = require 'gulp'
gutil = require 'gulp-util'
watch = require 'gulp-watch'
plumber = require 'gulp-plumber'
concat = require 'gulp-concat'
coffee = require 'gulp-coffee'
sass = require 'gulp-sass'
emberHandlebars = require './gulp/gulp-ember-handlebars'
buildIndex = require './gulp/gulp-build-index'
config = require './config.json'
server = require './server'

gulp.task 'index', ->
  gulp.src('src/index.hbs')
    .pipe(buildIndex(config.scripts))
    .pipe(gulp.dest('./_dev/'))

gulp.task 'copy', ->
  gulp.src('src/fonts/**/*').pipe(gulp.dest('./_dev/fonts/'))
  gulp.src('src/scripts/lib/*').pipe(gulp.dest('./_dev/scripts/lib/'))

gulp.task 'coffee', ->
  watchCoffee = watch glob: 'src/scripts/**/*.coffee'
  watchCoffee
    .pipe(plumber())
    .pipe(coffee().on('error', gutil.log))
    .pipe(gulp.dest('./_dev/scripts/'))

  watchCoffee.gaze.on 'all', (event)->
    if event is 'added' or event is 'deleted'
      gulp.run 'index'

gulp.task 'handlebars', ->
  watch(glob: 'src/scripts/**/*.hbs')
    .pipe(plumber())
    .pipe(emberHandlebars().on('error', gutil.log))
    .pipe(gulp.dest('./_dev/scripts/'))

gulp.task 'sass', ->
  watch(glob: 'src/stylesheets/!(_)*.scss')
    .pipe(sass())
    .pipe(gulp.dest('./_dev/stylesheets/'))

gulp.task 'watch', ['coffee', 'handlebars', 'sass']

gulp.task 'server', -> server 8080

gulp.task 'dev', ['index', 'copy', 'watch', 'server']

gulp.task 'default', ['dev']
