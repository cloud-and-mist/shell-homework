#!/usr/bin/env bash
function help {
    echo "-a                 统计不同年龄区间范围（20岁以下、[20-30]、30岁以上）的球员数量、百分比"
    echo "-p                 统计不同场上位置的球员数量、百分比"
    echo "-mn                 名字最长的球员是谁？名字最短的球员是谁？"
    echo "-ma                 年龄最大的球员是谁？年龄最小的球员是谁？"
    echo "-h                 帮助文档"
}
#首先检查有没有这个文件，如果没有的话要进行下载
CheckFile(){
    if [[ ! -f "worldcupplayerinfo.tsv" ]];then
        wget https://raw.githubusercontent.com/EddieXu1125/LinuxSysAdmin/master/exp/chap0x04/worldcupplayerinfo.tsv
    fi
}

#统计不同年龄区间范围（20岁以下、[20-30]、30岁以上）的球员数量、百分比
#-F指定分隔符
#$2!="Country"这个条件放在这里是为了略过第一行，如果第一行加入计算会出现问题
function CountAge {
    awk -F "\t" ' 
    BEGIN { a=0; b=0; c=0; }
    $2!="Country" {
        if ($6>=0&&$6<20) {a++;}
        if ($6>=20&&$6<=30) {b++;}
        else {c++;}
    }
    END {
        sum=a+b+c;
        printf("| 年龄区间\t | 人数\t | 百分比\t | \n");
        printf("| 20岁以下\t | %d\t | %.5f%%\t | \n",a,a*100.0/sum);
        printf("| [20,30]\t | %d\t | %.5f%%\t | \n",b,b*100.0/sum);
        printf("| 30岁以上\t | %d\t | %.5f%%\t | \n",c,c*100.0/sum);
    }
    ' worldcupplayerinfo.tsv
}
#统计不同场上位置的球员数量、百分比
function CountPosition {
    awk -F "\t" '
    BEGIN { total=0 }
    $2!="Country" {
        position[$5]++;
        total++;
    }
    END {
        printf("| 场上位置\t | 人数\t | 百分比\t | \n");
        for (pos in position){
            printf("| %s\t | %d\t | %.5f%%\t | \n",pos,position[pos],position[pos]*100.0/total);
        }
    }
    ' worldcupplayerinfo.tsv
}
#找出名字最长的球员和名字最短的球员，考虑到长度相等的情况
function NameLength {
    awk -F "\t" '
    BEGIN { max=0; min=1000; }
    $2!="Country" {
        len=length($9);
        name[$9]=len;
        if(len>max) max=len;
        if(len<min) min=len;
        }
    END {
        for(i in name) {
            if(name[i]==max) printf("名字最长的球员是：%s\n",i);
            if(name[i]==min) printf("名字最短的球员是：%s\n",i);
        }
    }
    ' worldcupplayerinfo.tsv
}
#找出年龄最大的球员和年龄最短的球员，考虑到年纪相等的情况
function AgeLength {
    awk -F "\t" '
    BEGIN { max=0; min=150; }
    $2!="Country" {
        age=$6;
        name[$9]=age;
        if(age>max) max=age;
        if(age<min) min=age;
    }
    END {
        for(i in name) {
            if(name[i]==max) printf("年龄最大的球员是：%s,他的年龄是：%d\n",i,name[i]);
            if(name[i]==min) printf("年龄最小的球员是：%s,他的年龄是：%d\n",i,name[i]);
        }
    }
    ' worldcupplayerinfo.tsv
}

# 先检查文件有没有，没有就下载
CheckFile

if [ "$1" != "" ];then #判断是什么操作
    case "$1" in
        "-h")
            help
            exit 0
            ;;
        "-a")
            CountAge
            exit 0
            ;;
        "-p")
            CountPosition
            exit 0
            ;;
        "-mn")
            NameLength
            exit 0
            ;;
        "-ma")
            AgeLength
            exit 0
            ;;
    esac
fi



