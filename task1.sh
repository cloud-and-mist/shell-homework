#!/usr/bin/env bash
function help {
    echo "-c Q               对jpeg格式图片进行图片质量因子为Q的压缩"
    echo "-r R               对jpeg/png/svg格式图片在保持原始宽高比的前提下压缩分辨率为R"
    echo "-w content size position   对图片批量添加自定义文本水印,content写入水印内容，size写入水印大小，position写入水印位置，如North,West.."
    echo "-p text            统一添加文件名前缀，不影响原始文件扩展名"
    echo "-s text            统一添加文件名后缀，不影响原始文件扩展名"
    echo "-t                 将png/svg图片统一转换为jpg格式图片"
    echo "-h                 帮助文档"
}

#对jpeg格式图片进行图片质量因子为Q的压缩
function CompressQuality {
    Q=$1
    for image in img/*;do #遍历文件夹img下面的所有文件
        type=${image##*.}#识别文件后缀
        if [[ ${type} != "jpeg"  ]]; then continue; fi;
        convert "${image}" -quality "${Q}" "${image}"
        echo "${image} is successfully compressed."
    done
}
#对jpeg/png/svg格式图片在保持原始宽高比的前提下压缩分辨率为R
function CompressResolution {
    R=$1
    for image in img/*;do
        type=${image##*.}
        if [[ ${type} == "jpeg" || ${type} == "png" || ${type} == "svg" ]]; then
            convert "${image}" -resize "${R}" "${image}"
            echo "${image} is resized successfully"
        fi;
    done
}
#对图片批量添加自定义文本水印
function WaterMark {
    content="$1"
    size=$2
    position="$3"
    for image in img/*;do
        convert "${image}" -pointsize "${size}" -fill red -gravity "${position}" -draw "text 10,10 '${content}'" "${image}"
        echo "${image} is watermarked with ${content} successfully"
    done
}
#对文件进行批量重命名（统一添加文件名前缀，不影响原始文件扩展名）
function AddPrefix {
    text="$1"
    for image in img/*;do
        name=${image##*/} #获得文件的真正名字，如果不进行这一步操作获得的文件名为img/balabal.jpeg
        new_name=img/"${text}${name}" #修改文件的名字，注意要把路径补全才可以用mv进行移动
        mv "${image}" "${new_name}"
        echo "${image} is renamed to ${text}${name}"
    done
}
#对文件进行批量重命名（统一添加文件名后缀，不影响原始文件扩展名）
function AddSuffix {
    text="$1"
    for image in img/*;do
        type=${image##*.} #此为去掉点之前内容只保留后缀
        new_name=${image%.*}${text}"."${type} #image%.*表示去掉点之后的内容，即去掉点和后缀
        mv "${image}" "${new_name}"
        echo "${image} is renamed to ${image%.*}${text}.${type}"
    done
}
#将png/svg图片统一转换为jpg格式图片
function TransformToJpg {
    for image in img/*;do
        type=${image##*.}
        if [[ ${type} == "png" || ${type} == "svg" ]]; then
            new_name=${image%.*}${text}".jpg"
            convert "${image}" "${new_name}"
            echo "${image} has transformed into ${new_name}"
        fi
    done
}

if [ "$1" != "" ];then #判断命令行要求做什么操作
    case "$1" in
        "-h")
            help
            exit 0
            ;;
        "-c")
            CompressQuality "$2"
            exit 0
            ;;
        "-r")
            CompressResolution "$2"
            exit 0
            ;;
        "-w")
            WaterMark "$2" "$3" "$4"
            exit 0
            ;;
        "-p")
            AddPrefix "$2"
            exit 0
            ;;
        "-s")
            AddSuffix "$2"
            exit 0
            ;;
        "-t")
            TransformToJpg
            exit 0
            ;;
    esac
fi