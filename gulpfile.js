var gulp = require('gulp');
var copy = require('gulp-copy');
var del = require('del');

gulp.task('default', ['img', 'css', 'font', 'js']);

gulp.task('clean:img', function () {
    return del(['public/img']);
});

gulp.task('img', ['clean:img'], function () {
    return gulp.src('resources/img/**/*')
        .pipe(gulp.dest('public/img'));
});

gulp.task('clean:css', function () {
    return del(['public/css']);
});

gulp.task('css', ['clean:css'], function () {
    gulp.src(['resources/css/**/*.css'])
        .pipe(gulp.dest('public/css'));

    gulp
        .src([
            'node_modules/bootstrap/dist/css/bootstrap.min.css',
            'node_modules/x-editable/dist/bootstrap3-editable/css/bootstrap-editable.css',
            'node_modules/bootstrap-table/dist/bootstrap-table.min.css',
            'node_modules/bootstrap-datepicker/dist/css/bootstrap-datepicker3.css'
        ])
        .pipe(gulp.dest('public/css'));
});

gulp.task('clean:font', function() {
    return del(['public/fonts']);
});

gulp.task('font', ['clean:font'], function() {
    return gulp.src([
        'node_modules/bootstrap/dist/fonts/*',
    ]).pipe(gulp.dest('public/fonts'));
});

gulp.task('clean:js', function () {
    return del(['public/js']);
});

gulp.task('js', ['clean:js'], function () {
    gulp.src(['resources/js/**/*.js'])
        .pipe(gulp.dest('public/js'));

    gulp
        .src([
            'node_modules/jquery/dist/jquery.min.js',
            'node_modules/bootstrap/dist/js/bootstrap.min.js',
            'node_modules/bootstrap-table/dist/bootstrap-table.min.js',
            'node_modules/bootstrap-datepicker/dist/js/bootstrap-datepicker.js',
            'node_modules/bootstrap-table/dist/extensions/editable/bootstrap-table-editable.min.js',
            'node_modules/x-editable/dist/bootstrap3-editable/js/bootstrap-editable.js'
        ])
        .pipe(gulp.dest('public/js'));
});
