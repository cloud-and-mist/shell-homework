#!/usr/bin/env bash
function help {
    echo "-a      统计访问来源主机TOP 100和分别对应出现的总次数"
    echo "-b      统计访问来源主机TOP 100 IP和分别对应出现的总次数"
    echo "-u      统计最频繁被访问的URL TOP 100"
    echo "-p      统计不同响应状态码的出现次数和对应百分比"
    echo "-f      分别统计不同4XX状态码对应的TOP 10 URL和对应出现的总次数"
    echo "-s URL  给定URL输出TOP 100访问来源主机"
    echo "-h      帮助文档"
}

CheckFile(){
    if [[ ! -f "web_log.tsv.7z" ]];then
        wget https://c4pr1c3.github.io/LinuxSysAdmin/exp/chap0x04/web_log.tsv.7z
        7z x web_log.tsv.7z
    elif [[ ! -f "web_log.tsv" ]];then
        7z x web_log.tsv.7z
    fi
}

# 统计访问来源主机TOP 100和分别对应出现的总次数
#sort -g -k 2 -r其中的2表示对第二列数据进行比较，而我输出的第二列数据为出现次数，因此是按照出现次数进行比较。注意输出时的|算是第一列
function CountHost {
    printf "| 出现次数\t | 来源主机名称\t |\n"
    awk -F "\t" '
    $1!="host" {host[$1]++;}
    END{
        
        for( h in host ){
            printf(" %d\t  %s\t  \n",host[h],h);
        }
    }
    ' web_log.tsv | sort -g -k 1 -r | head -100
}
#统计访问来源主机TOP 100 IP和分别对应出现的总次数
function CountIP {
    printf "| 出现次数\t | 来源主机ip\t |\n"
    awk -F "\t" '
    $1!="host" {
        if(match($1,/^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$/)){
            host[$1]++;
        }
    }
    END {
        for( h in host )
        {
            printf(" %d\t  %s\t  \n",host[h],h);
        }
    }
    ' web_log.tsv | sort -g -k 1 -r | head -100
}
#统计最频繁被访问的URL TOP 100
function FrequentURL {
    printf "| 访问次数\t | URL\t |\n"
    awk -F "\t" '
    $1!="host" { url[$5]++; }
    END {
        for( u in url )
        {
            printf(" %d\t  %s\t  \n",url[u],u);
        }
    }
    ' web_log.tsv | sort -g -k 1 -r | head -100
}
#统计不同响应状态码的出现次数和对应百分比
function CountState {
    printf "| 状态码\t | 出现次数\t | 所占百分比\t |\n"
    awk -F "\t" '
    BEGIN {total=0;}
    $1!="host" {
        state[$6]++;
        total++;
    }
    END {
        for( s in state )
        {
            printf(" %s\t  %d\t  %.5f%%\t  \n",s,state[s],state[s]*100.0/total);
        }
    }
    ' web_log.tsv
}
#分别统计不同4XX状态码对应的TOP 10 URL和对应出现的总次数
#match($6,/^4[0-9]{2}$/)中{2}表示[0-9]出现两次
#两次输出不同在于第二个多了个r是为了输出404的top10
#sort -k1,1 -k2,2gr表示先按照第一个域排序，在第一个域处于并列状态的情况下对第二个域进行排序，即排对应出现的总次数
function CountState4XX {
    printf "|4XX状态码|出现次数|出现该现象的网址|\n"
    awk -F '\t' '
    $1!="host" {
        if(match($6,/^4[0-9]{2}$/)){
            urls[$6][$5]++;
        }
    }
    END{ 
        for(k1 in urls){
            for(k2 in urls[k1]){
                print k1, urls[k1][k2], k2;
            }
        }
    }' web_log.tsv | sort -k1,1 -k2,2gr | head -10
    awk -F '\t' '
    $1!="host" {
        if(match($6,/^4[0-9]{2}$/)){
            urls[$6][$5]++;
        }
    }
    END{ 
        for(k1 in urls){
            for(k2 in urls[k1]){
                print k1, urls[k1][k2], k2;
            }
        }
    }' web_log.tsv | sort -k1,1r -k2,2gr | head -10
}
#给定URL输出TOP 100访问来源主机
function FindHost {
    printf "| 访问次数\t | 来源主机\t |\n"
    awk -F '\t' -v url="$1" '
    $1!="host" {
        if(url==$5)
        {
            urls[$1]++;
        }
    }
    END {
        for( u in urls ){
            printf(" %d\t  %s\t  \n",urls[u],u);
        }
    }
    ' web_log.tsv | sort -g -k 1 -r | head -100
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
            CountHost
            exit 0
            ;;
        "-b")
            CountIP
            exit 0
            ;;
        "-u")
            FrequentURL
            exit 0
            ;;
        "-p")
            CountState
            exit 0
            ;;
        "-f")
            CountState4XX
            exit 0
            ;;
        "-s")
            FindHost "$2"
            exit 0
            ;;
    esac
fi