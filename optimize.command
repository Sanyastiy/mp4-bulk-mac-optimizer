#!/bin/bash
# Интро, здесь переменные, чтобы управлять настройками удобнее
clear; # Legacy

echo -e "\033[1mМагистр\033[0m, приветствую, готов к оптимизации видео"
echo -e "\033[90mКодек: \033[4m  -c:v libx264 -crf 25 -tune zerolatency \033[0m"
butt_temp=$(ioreg -n AppleSmartBattery | grep -E '"Temperature"' | awk '{print $7}')
butt_tempvirt=$(ioreg -n AppleSmartBattery | grep -E '"VirtualTemperature"' | awk '{print $7}')
echo -e "\033[90mТекущая температура батареи: Сенсор1: $butt_temp, Сенсор2:$butt_tempvirt \033[0m"

total_size_optimized=0

# Функция для обхода файлов и папок
process_files() {
    local dir="$1"

    # Подсчет файлов в текущей папке
    local total_count=0
    for file in "$dir"/*; do
        if [[ -f "$file" && "${file##*.}" == "mp4" && "$file" != *".tmp"* ]]; then
            (( ++total_count ))
        fi
    done

    local video_count=0
    local counter_file="$dir/processed-index.txt"
    # Считываем значение из файла в переменную
    if [[ -f "$counter_file" ]]; then
        # Считываем значение из файла в переменную
        local index_count=$(<"$counter_file")
        else
        local index_count=0
    fi

    # Обрабатываем только файлы, начиная с сохранённого индекса
    for file in "$dir"/*; do
        # Если это папка, рекурсивно вызываем process_files
        if [[ -d "$file" ]]; then
    
            process_files "$file"

        # Если это файл с расширением .mp4 и не .tmp, оптимизируем его
        elif [[ -f "$file" && "${file##*.}" == "mp4" && "$file" != *".tmp"* ]]; then
            # Двигаемся до нужного файла, на котором остановились в прошлый раз
            if (( video_count >= index_count )); then
                # Как только дошли, начинаем работу
                if (( video_count == index_count )); then

                    # Получаем канонический путь к файлу
                    file_relative=$(realpath "$file")
                    # Удаляем часть пути, соответствующую директории скрипта
                    file_relative=${file_relative#$(dirname "$0")/}
                    

                    # С бережностью к технике
                    butt_temp=$(ioreg -n AppleSmartBattery | grep -E '"Temperature"' | awk '{print $7}')
                    butt_tempvirt=$(ioreg -n AppleSmartBattery | grep -E '"VirtualTemperature"' | awk '{print $7}')
                    butt_temp=$(expr "$butt_temp" + 0)
                    butt_tempvirt=$(expr "$butt_tempvirt" + 0)

                    if [ "$butt_temp" -ge 3300 ] || [ "$butt_tempvirt" -ge 3800 ]; then
                        while [ "$butt_temp" -ge 3300 ] || [ "$butt_tempvirt" -ge 3800 ]; do
                            if [ "$butt_temp" -ge 3500 ] || [ "$butt_tempvirt" -ge 4100 ]; then
                                echo -e "\033[31m Один из датчиков фиксирует высокий нагрев ($butt_temp, $butt_tempvirt) \033[0m"
                            fi
                            echo -e "\033[33m Один из датчиков фиксирует нагрев ($butt_temp, $butt_tempvirt), \033[34m чилим \033[0m"
                            chill_time=360
                            for (( i=1; i<=$chill_time; i++ )); do
                                echo -ne "\r \033[34m Чилим ещё: $((chill_time-i)) секунд \033[0m"
                                sleep 1
                            done
                            echo # для перехода на следующую строку после отсчета
                            # Ещё раз смотрим температуру
                            butt_temp=$(ioreg -n AppleSmartBattery | grep -E '"Temperature"' | awk '{print $7}')
                            butt_tempvirt=$(ioreg -n AppleSmartBattery | grep -E '"VirtualTemperature"' | awk '{print $7}')
                            butt_temp=$(expr "$butt_temp" + 0)
                            butt_tempvirt=$(expr "$butt_tempvirt" + 0)
                        done
                        else # Температура стабилизировалась, продолжаем

                        echo -e "\033[33m Оптимизирую $file_relative, это $video_count из $total_count \033[0m"
                        # Определяем размер оригинального файла в мегабайтах
                        orig_size=$(du -m "$file" | awk '{print $1}')
                        echo -e "\033[0m  Температура батареи в норме, Сенсор1:$butt_temp, Сенсор2:$butt_tempvirt всё как мы любим, работаем \033[0m"
                        start_time=$SECONDS
                        # Опция ffmpeg без ограничения cpulimit
                        
                        # bad compression, breacking videos! high speed
                        #cpulimit -l 100 ffmpeg -i "$file" -c:v hevc_videotoolbox -q:v 35 -c:a aac -loglevel warning -hide_banner -movflags +faststart "$file.tmp.mp4"
                        
                        # good compression, lossless, low speed
                         cpulimit -l 100 ffmpeg -i "$file" -c:v libx264 -crf 25 -tune zerolatency -c:a aac -loglevel warning -hide_banner -movflags +faststart "$file.tmp.mp4"
                        
                        # bad compression, lossless, high speed
                        # cpulimit -l 100 ffmpeg -hwaccel videotoolbox -i "$file" -c:v h264_videotoolbox -c:a aac -loglevel warning -hide_banner -movflags +faststart "$file.tmp.mp4"
                        # Опция ffmpeg с ограничением cpulimit
                        # cpulimit -l 50 ffmpeg -i "$file" -c:v libx264 -tune zerolatency -c:a aac -crf 25 -loglevel warning -hide_banner -movflags +faststart "$file.tmp.mp4"
                        # Опция ffmpeg с ограничением cpulimit и попыткой использовать h264_videotoolbox с апаратным ускорением
                        # cpulimit -l 50 ffmpeg -i "$file" -c:v h264_videotoolbox -c:a aac -loglevel warning -hide_banner -movflags +faststart "$file.tmp.mp4"

                        execution_time=$((SECONDS - start_time))
                        
                        # Определяем размер оптимизированного файла в мегабайтах
                        optimized_size=$(du -m "$file.tmp.mp4" | awk '{print $1}')

                        # Вычисляем время выполнения
                        if ((execution_time > 60)); then
                            minutes=$((execution_time / 60))
                            seconds=$((execution_time % 60))
                            echo "  Видео обработалось за: $minutes минут и $seconds секунд"
                            else
                            echo "  Видео обработалось за: $execution_time секунд"
                        fi
                        # Выводим размеры файлов
                        echo "  Размер: $orig_size MB > $optimized_size MB"

                        # Сравниваем размеры файлов
                        if (( optimized_size < orig_size )); then
                            echo -e "\033[32m  Оптимизация успешна, обновляю файл \033[0m"
                            mv -f "$file.tmp.mp4" "$file"
                            total_size_optimized=$((total_size_optimized + orig_size - optimized_size))
                            else
                            echo -e "\033[31m  Оптимизация не успешна, оставляю файл как есть \033[0m"
                            rm "$file.tmp.mp4"
                        fi

                    fi
                    else
                    echo -e "\033[32m $file_relative уже оптимизирован, это $video_count из $total_count \033[0m"
                fi
            # Увеличиваем значение счетчика пройденных видео
            (( index_count++ ))
            fi
            # Увеличиваем значение счетчика оптимизированных видео
            (( video_count++ ))
            # Обновляем значение счетчика в файле
            echo "$video_count" > "$counter_file"
        fi
    done
}

# Получаем текущую директорию
current_dir=$(dirname "$(realpath "$0")")

# Переходим в текущую директорию
cd "$current_dir" || exit

# Удаление всех временных файлов
find . -name "*.tmp.mp4" -delete

# Проверяем наличие файла о завершении всех оптимизаций
if [[ -f "$current_dir/all-optimization-completed-index-files-removed.txt" ]]; then
    echo "Все готово, если хочешь начать заново, удали файл о завершении"
    exit 0
fi

# Вызываем функцию для обработки файлов и папок и начинаем цикл
process_files "$current_dir"

# Концовка
# Удаление всех файлов счетчиков внутри папок
find . -name "processed-index.txt" -delete
# Создание файла для обозначения завершения всех оптимизаций
touch "all-optimization-completed-index-files-removed.txt"
echo -e "\033[32m Оптимизация завершена. \033[0m"
echo -e "\033[32m Всего сохранено пространства: $total_size_optimized MB. \033[0m"
exit 0
