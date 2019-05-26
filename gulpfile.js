const gulp = require('gulp');
const concat = require('gulp-concat');
 
gulp.task('default', function() {
  return gulp.src([
      './src/misc.lua',
      './src/nearest.lua',
      './src/vector2.lua',
      './src/set.lua',
      './src/map.lua',
      './src/priority-queue.lua',
      './src/pathfinding.lua',
      './src/main.lua'
    ])
    .pipe(concat('main.lua', {newLine: '\n\n'}))
    .pipe(gulp.dest('./build/'));
});