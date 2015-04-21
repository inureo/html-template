gulp        = require 'gulp'
runSequence = require 'run-sequence'
$           = require('gulp-load-plugins')({
  pattern: ['gulp-*', 'gulp.*'],
  replaceString: /\bgulp[\-.]/
})

tsProject = $.typescript.createProject({
  target: 'ES5',
  removeComments: true,
  sortOutput: true
})

gulp.task 'typescript', ->
  gulp.src('./src/ts/*.ts')
  .pipe $.plumber({
    errorHandler: (error) ->
      console.log(error.message)
      this.emit('end')
  })
  .pipe $.typescript(tsProject)
  .pipe $.concat('app.js')
  .pipe gulp.dest('./src/js/')

gulp.task 'sass', ->
  gulp.src('./src/css/style.sass')
  .pipe $.plumber({
    errorHandler: (error) ->
      console.log(error.message)
      this.emit('end')
  })
  .pipe $.compass({
      config_file: './config.rb',
      comments: false,
      css: 'dist/css/',
      sass: 'src/css/'
    }
  )
  .pipe gulp.dest('./dist/css/')

gulp.task 'slim', ->
  gulp.src(['src/slim/*.slim', 'src/slim/**/*.slim', '!src/slim/partial/*'])
  .pipe $.cached('slim')
  .pipe $.plumber({
    errorHandler: (error) ->
      console.log(error.message)
      this.emit('end')
  })
  .pipe($.shell([
      'slimrb -r slim/include -p <%= file.path %> > ./dist/<%= file.relative.replace(".slim", ".html") %>'
    ]))

gulp.task 'compress', ->
  gulp.src([
    './src/js/*.js'
  ])
  .pipe $.uglify()
  .pipe $.concat('app.min.js')
  .pipe gulp.dest('./dist/js/')

gulp.task 'js-build', ->
  runSequence(
    'typescript',
    'compress'
  )

gulp.task 'server', ->
  gulp.src './dist/'
  .pipe $.webserver({
    host: '0.0.0.0',
    livereload: true,
    port: 8000
  })

gulp.task 'watch', ->
  gulp.watch('src/css/*.sass',     ['sass'])
  gulp.watch('src/css/**/*.sass',  ['sass'])
  gulp.watch('src/slim/*.slim',    ['slim'])
  gulp.watch('src/slim/**/*.slim', ['slim'])
  gulp.watch('src/ts/*.ts',        ['js-build'])

gulp.task 'default', ['server', 'watch']
