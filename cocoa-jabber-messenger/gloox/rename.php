<?php
exec('ls *.cpp', $output);
foreach($output as $file){
    $filename = rtrim($file, '.cpp');
    echo $filename."\n";
    exec("mv {$file} {$filename}.mm");
}

