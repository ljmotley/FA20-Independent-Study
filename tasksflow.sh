if [ "$#" -eq  "0" ]
    then
      echo -e 'digraph G {' > tasksflow.txt #Start graph
      find tasks -type l -ls | awk '{print $13 " -> " $11}' | #List symbolic links
      sed 's/\.\.\///g' | sed 's/tasks\///g' | #Drop relative paths
      sed 's/\/\(input\)\/[a-zA-Z0-9_\.]*//g' | #Retain only task names; drop filenames
      sed 's/\/\(temp\)\/[a-zA-Z0-9_\.]*//g' | #Retain only task names; drop filenames
      sed 's/\/\(output\)\/[a-zA-Z0-9_\.]*//g' >> tasksflow.txt
      echo '}' >> tasksflow.txt
    else
      echo -e 'digraph G {' > tasksflow.txt #Start graph
      find tasks -type l -ls | awk '{print $13 " -> " $11}' | #List symbolic links
      sed 's/\.\.\///g' | sed 's/tasks\///g' | #Drop relative paths
      sed 's/\/\(input\)\/[a-zA-Z0-9_\.]*//g' | #Retain only task names; drop filenames
      sed 's/\/\(temp\)\/[a-zA-Z0-9_\.]*//g' | #Retain only task names; drop filenames
      sed 's/\/\(output\)\/[a-zA-Z0-9_\.]*//g' |
      sed '/'$1'/ s/$/ [color =blue, fillcolor = blue]/' >> tasksflow.txt
      echo ''$1' [color = blue, fontcolor = blue]' >> tasksflow.txt
      echo '}' >> tasksflow.txt
fi
dot -Grankdir=LR -Tpng tasksflow.txt -o tasksflow.png
rm tasksflow.txt
