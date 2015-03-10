gulp = require 'gulp'
$    = require('gulp-load-plugins')({
         pattern: ['gulp-*', 'gulp.*'],
         replaceString: /\bgulp[\-.]/
       })

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
      css: 'css/',
      sass: 'src/css/'
    }
  )
  .pipe gulp.dest('css/')

gulp.task 'slim', ->
  gulp.src('src/slim/*.slim')
  .pipe $.cached('slim')
  .pipe $.plumber({
    errorHandler: (error) ->
      console.log(error.message)
      this.emit('end')
  })
  .pipe $.shell([
      'slimrb -r slim/include -p <%= file.path %> > ./<%= file.relative.replace(".slim", ".html") %>'
    ])

gulp.task 'server', ->
  gulp.src './'
  .pipe $.webserver({
    livereload: true
    port: 8000,
    directoryListing: true
  })

gulp.task 'watch', ->
  gulp.watch('src/css/*.sass', ['sass'])
  gulp.watch('src/css/**/*.sass', ['sass'])
  gulp.watch('src/slim/*.slim', ['slim'])
  gulp.watch('src/slim/partial/*.slim', ['slim'])

gulp.task 'default', ['sass', 'server', 'watch']