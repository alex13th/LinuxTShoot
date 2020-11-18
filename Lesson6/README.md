# Практическое задание 6

## (ВЫПОЛНЕНО) 1. Скачиваем архив и загружаем скрипты а так же файл memory на сервер в домашнюю папку root пользователя
## (ВЫПОЛНЕНО) 2. Делаем, в том числе, и файл memory исполняемым (#chmod +x memory).
## (ВЫПОЛНЕНО) 3. **ВНИМАНИЕ!!!** Если у вас стоит не самая последняя версия centos7, то делаем скрипт lab1.sh если у вас уже все обновлено, то скрипт lab1 ничего не сделает. Так что в зачет он не идет
## (ВЫПОЛНЕНО) 4. Запускаем скрипт lab2.sh , после чего пробуем запустить программу nmap -sn 8.8.8.0/24. Определите в чем проблема и почините

### 4.1 Проверяем наличие проблемы

<pre>
# nmap -sn 8.8.8.0/24
nmap: error while loading shared libraries: libpcap.so.1: cannot open shared object file: No such file or directory
</pre>

Судя по выводу в системе не хватает библиотеки **libpcap.so.1**.


### 4.2 Узнаем имя пакета предоставляющего библиотеку libpcap.so.1:
<pre>
# yum provides libpcap.so.1

Loaded plugins: fastestmirror, versionlock
Loading mirror speeds from cached hostfile
 * base: mirror.truenetwork.ru
 * extras: mirror.truenetwork.ru
 * updates: mirror.truenetwork.ru
Excluding 1 update due to versionlock (use "yum versionlock status" to show it)
14:<b>libpcap-1.5.3-12.el7.i686</b> : A system-independent interface for user-level packet capture
Repo        : base
Matched from:
Provides    : libpcap.so.1
</pre>

### 4.3 Пробуем установить libpcap-1.5.3-12.el7.i686:

<pre>
# yum install libpcap-1.5.3-12.el7.i686 -y
Loaded plugins: fastestmirror, versionlock
Loading mirror speeds from cached hostfile
 * base: mirror.truenetwork.ru
 * extras: mirror.truenetwork.ru
 * updates: mirror.truenetwork.ru
Excluding 1 update due to versionlock (use "yum versionlock status" to show it)
Resolving Dependencies
--> Running transaction check
---> Package libpcap.i686 14:1.5.3-12.el7 will be installed
--> Processing Dependency: libc.so.6(GLIBC_2.11) for package: 14:libpcap-1.5.3-12.el7.i686
--> Finished Dependency Resolution
<b>Error: Package: 14:libpcap-1.5.3-12.el7.i686 (base)
           Requires: libc.so.6(GLIBC_2.11)</b>
 You could try using --skip-broken to work around the problem
 You could try running: rpm -Va --nofiles --nodigest
</pre>



### 4.3 Узнаем имя пакета предоставляющего библиотеку libpcap.so.1:

<pre>
# yum provides libc.so.6

<b>Excluding 1 update due to versionlock (use "yum versionlock status" to show it)</b>
base/7/x86_64/filelists_db                                                                                                        | 7.2 MB  00:00:13     
extras/7/x86_64/filelists_db                                                                                                      | 224 kB  00:00:00     
updates/7/x86_64/filelists_db                                                                                                     | 1.2 MB  00:00:03     
No matches found
</pre>

Не удалось определить имя пакета, но получена информация о том, что в системе заблокирован один пакет обновлений.


### 4.4 По подсказке yum проверяем versionlock

<pre>
# yum versionlock status

Loaded plugins: fastestmirror, versionlock
Loading mirror speeds from cached hostfile
 * base: mirror.truenetwork.ru
 * extras: mirror.truenetwork.ru
 * updates: mirror.truenetwork.ru
<b>0:glibc-2.17-317.el7.*</b>
versionlock status done
</pre>

Судя но названию это как раз необходимый пакет.

### 4.6 Удаляем блокировку версии

<pre>
# yum versionlock delete glibc-2.17*

Loaded plugins: fastestmirror, versionlock
Deleting versionlock for: 0:glibc-2.17-307.el7.1.*
versionlock deleted: 1
</pre>

### 4.6 Снова пробуем установить libpcap-1.5.3-12.el7.i686:

<pre>
# yum install libpcap-1.5.3-12.el7.i686 -y
Installed:
  libpcap.i686 14:1.5.3-12.el7                                                                                                                           

Dependency Installed:
  glibc.i686 0:2.17-317.el7                                           nss-softokn-freebl.i686 0:3.53.1-6.el7_9                                          

Dependency Updated:
  glibc.x86_64 0:2.17-317.el7         glibc-common.x86_64 0:2.17-317.el7    nspr.x86_64 0:4.25.0-2.el7_9    nss-softokn-freebl.x86_64 0:3.53.1-6.el7_9   
  nss-util.x86_64 0:3.53.1-1.el7_9   

Complete!
Dependency Installed:
  glibc.i686 0:2.17-317.el7                                           nss-softokn-freebl.i686 0:3.53.1-6.el7_9                                          

Dependency Updated:
  glibc.x86_64 0:2.17-317.el7         glibc-common.x86_64 0:2.17-317.el7    nspr.x86_64 0:4.25.0-2.el7_9    nss-softokn-freebl.x86_64 0:3.53.1-6.el7_9   
  nss-util.x86_64 0:3.53.1-1.el7_9   

Complete!
</pre>

### 4.7 Проверяем наличие проблемы

<pre>
# nmap -sn 8.8.8.0/24
nmap: error while loading shared libraries: libpcap.so.1: cannot open shared object file: No such file or directory
</pre>

**Проблема НЕ решена**

### 4.8 Проверяем базу RPM

<pre>
#rpm -Va

S.5....T.  c /etc/sysconfig/authconfig
.......T.  c /etc/yum/pluginconf.d/versionlock.list
<b>missing     /usr/lib64/libpcap.so.1
missing     /usr/lib64/libpcap.so.1.5.3</b>
.M.......  g /etc/pki/ca-trust/extracted/java/cacerts
.M.......  g /etc/pki/ca-trust/extracted/openssl/ca-bundle.trust.crt
.M.......  g /etc/pki/ca-trust/extracted/pem/email-ca-bundle.pem
.M.......  g /etc/pki/ca-trust/extracted/pem/objsign-ca-bundle.pem
.M.......  g /etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem
</pre>

### 4.9 Определяем имя пакета, которому приндалежит файл libpcap.so.1
<pre>
# rpm -qf /usr/lib64/libpcap.so.1
libpcap-1.5.3-12.el7.x86_64
</pre>

### 4.10 Пробуем переустановить пакет libpcap-1.5.3-12.el7.x86_64

<pre>
# yum reinstall libpcap-1.5.3-12.el7.x86_64

Loaded plugins: fastestmirror, versionlock

......
......

Running transaction
  Installing : 14:libpcap-1.5.3-12.el7.x86_64                                                                                                        1/1 
  Verifying  : 14:libpcap-1.5.3-12.el7.x86_64                                                                                                        1/1

Installed:
  libpcap.x86_64 14:1.5.3-12.el7

Complete!
</pre>

### 4.11 Проверяем наличие проблемы

<pre>
# nmap -sn 8.8.8.0/24

Starting Nmap 6.40 ( http://nmap.org ) at 2020-11-18 01:34 EST
</pre>

**Проблема РЕШЕНА**
<br><br>
P.S. Путь решения не оптимальный, но как получилось, так получилось.


## 5. (ВЫПОЛНЕНО) Запускаем скрипт lab3.sh (в отдельной вкладке либо как бэкграунд процесс) и подождите несколько минут. Найдите приложение, у которого утекает память.

В утилите top процессы отсортированы по потреблению памяти

<pre>
top - 01:51:58 up 56 min,  3 users,  load average: 0,00, 0,01, 0,05
Tasks: 102 total,   1 running, 101 sleeping,   0 stopped,   0 zombie
%Cpu(s):  0,0 us,  0,0 sy,  0,0 ni,100,0 id,  0,0 wa,  0,0 hi,  0,0 si,  0,0 st
KiB Mem :   995684 total,    82712 free,   306504 used,   606468 buff/cache
KiB Swap:  2097148 total,  2097140 free,        8 used.   527096 avail Mem 

   PID USER      PR  NI    VIRT    RES    SHR S %CPU %MEM     TIME+ COMMAND    
  <b>2098 root      20   0  378704 103660    340 S  0,0 10,4   0:00.01 memory     </b>
   703 root      20   0  358756  30732   6792 S  0,0  3,1   0:00.32 firewalld  
   995 root      20   0  574304  19484   6144 S  0,0  2,0   0:00.42 tuned      
   662 polkitd   20   0  612984  12948   4860 S  0,0  1,3   0:00.03 polkitd    
   727 root      20   0  628228   9172   6900 S  0,0  0,9   0:00.18 NetworkMan+
     1 root      20   0  128140   6720   4156 S  0,0  0,7   0:00.90 systemd    
  1702 root      20   0  156800   5688   4364 S  0,0  0,6   0:00.37 sshd       
  2080 root      20   0  156796   5684   4356 S  0,0  0,6   0:00.09 sshd       
  1768 root      20   0  102904   5476   3416 S  0,0  0,5   0:00.01 dhclient   
   507 root      20   0   48284   5248   2856 S  0,0  0,5   0:00.09 systemd-ud+
   998 root      20   0  214456   4464   3260 S  0,0  0,4   0:00.21 rsyslogd   
   996 root      20   0  112924   4336   3308 S  0,0  0,4   0:00.02 sshd       
  1166 postfix   20   0   89876   4084   3080 S  0,0  0,4   0:00.00 qmgr       
   500 root      20   0  127372   4076   2564 S  0,0  0,4   0:00.00 lvmetad    
  1165 postfix   20   0   89808   4068   3068 S  0,0  0,4   0:00.00 pickup     
   479 root      20   0   37112   3132   2820 S  0,0  0,3   0:00.14 systemd-jo+
   669 dbus      20   0   66472   2572   1876 S  0,0  0,3   0:00.10 dbus-daemon
   705 root      20   0   96568   2440   1784 S  0,0  0,2   0:00.07 login      
  9706 root      20   0  162152   2312   1560 R  0,0  0,2   0:00.01 top        
  1161 root      20   0   89704   2132   1124 S  0,0  0,2   0:00.00 master     
  1707 root      20   0  115544   2116   1680 S  0,0  0,2   0:00.08 bash       
  1254 root      20   0  115540   2076   1652 S  0,0  0,2   0:00.04 bash       
  2084 root      20   0  115548   2016   1604 S  0,0  0,2   0:00.00 bash       
   668 root      20   0   26380   1796   1476 S  0,0  0,2   0:00.03 systemd-lo+
   675 chrony    20   0  117808   1704   1276 S  0,0  0,2   0:00.05 chronyd    
  2015 root      20   0  126388   1656   1036 S  0,0  0,2   0:00.12 crond      
  2097 root      20   0  113284   1204   1016 S  0,0  0,1   0:00.00 lab3.sh    
  1742 root      20   0  125484   1112    872 S  0,0  0,1   0:00.00 anacron    
   637 root      16  -4   55532    852    448 S  0,0  0,1   0:00.01 auditd    
</pre>

Обнаружено приложение **memory**, которое потребляет памяти больше чем любой другой процесс и продолжает увеличивать потребление.



## 6. (ВЫПОЛНЕНО, без второй части) Попробуйте проанализировать его при помощи valgrind. При наличии у вас достаточного времени дождитесь пока память не кончится совсем и посмотрите в логах операционной системы что происходит.

### 6.1 Проверка с плагином **memcheck**

<pre>
# valgrind --tool=memcheck ./memory 

==9820== Memcheck, a memory error detector
==9820== Copyright (C) 2002-2017, and GNU GPL'd, by Julian Seward et al.
==9820== Using Valgrind-3.15.0 and LibVEX; rerun with -h for copyright info
==9820== Command: ./memory
==9820== 
^C==9820== 
==9820== Process terminating with default action of signal 2 (SIGINT)
==9820==    at 0x4EFC840: __nanosleep_nocancel (in /usr/lib64/libc-2.17.so)
==9820==    by 0x4EFC6F3: sleep (in /usr/lib64/libc-2.17.so)
==9820==    by 0x400584: main (in /root/memory)
==9820== 
==9820== HEAP SUMMARY:
<b>==9820==     in use at exit: 48,128,000 bytes in 47 blocks
==9820==   total heap usage: 47 allocs, 0 frees, 48,128,000 bytes allocated</b>
==9820== 
==9820== LEAK SUMMARY:
<b>==9820==    definitely lost: 44,032,000 bytes in 43 blocks</b>
==9820==    indirectly lost: 0 bytes in 0 blocks
==9820==      possibly lost: 3,072,000 bytes in 3 blocks
==9820==    still reachable: 1,024,000 bytes in 1 blocks
==9820==         suppressed: 0 bytes in 0 blocks
==9820== Rerun with --leak-check=full to see details of leaked memory
==9820== 
==9820== For lists of detected and suppressed errors, rerun with: -s
==9820== ERROR SUMMARY: 0 errors from 0 contexts (suppressed: 0 from 0)
</pre>

### 6.2 Проверка с дополнительной опцией **--leak-check=full**

<pre>
# valgrind <b>-s --leak-check=full</b> --tool=memcheck './memory'
==9851== Memcheck, a memory error detector
==9851== Copyright (C) 2002-2017, and GNU GPL'd, by Julian Seward et al.
==9851== Using Valgrind-3.15.0 and LibVEX; rerun with -h for copyright info
==9851== Command: ./memory
==9851== 
^C==9851== 
==9851== Process terminating with default action of signal 2 (SIGINT)
==9851==    at 0x4EFC840: __nanosleep_nocancel (in /usr/lib64/libc-2.17.so)
==9851==    by 0x4EFC6F3: sleep (in /usr/lib64/libc-2.17.so)
==9851==    by 0x400584: main (in /root/memory)
==9851== 
==9851== HEAP SUMMARY:
==9851==     in use at exit: 36,864,000 bytes in 36 blocks
==9851==   total heap usage: 36 allocs, 0 frees, 36,864,000 bytes allocated
==9851== 
<b>==9851== 2,048,000 bytes in 2 blocks are possibly lost in loss record 2 of 3
==9851==    at 0x4C29F73: malloc (vg_replace_malloc.c:309)
==9851==    by 0x400576: main (in /root/memory)</b>
==9851== 
==9851== 33,792,000 bytes in 33 blocks are definitely lost in loss record 3 of 3
==9851==    at 0x4C29F73: malloc (vg_replace_malloc.c:309)
==9851==    by 0x400576: main (in /root/memory)
==9851== 
==9851== LEAK SUMMARY:
==9851==    definitely lost: 33,792,000 bytes in 33 blocks
==9851==    indirectly lost: 0 bytes in 0 blocks
==9851==      possibly lost: 2,048,000 bytes in 2 blocks
==9851==    still reachable: 1,024,000 bytes in 1 blocks
==9851==         suppressed: 0 bytes in 0 blocks
==9851== Reachable blocks (those to which a pointer was found) are not shown.
==9851== To see them, rerun with: --leak-check=full --show-leak-kinds=all
==9851== 
<b>==9851== ERROR SUMMARY: 2 errors from 2 contexts (suppressed: 0 from 0)</b>
</pre>


### 6.3 Проверка с дополнительной опцией **--show-leak-kinds=all**

<pre>
# valgrind -s --leak-check=full <b>--show-leak-kinds=all</b> --tool=memcheck './memory'
==9853== Memcheck, a memory error detector
==9853== Copyright (C) 2002-2017, and GNU GPL'd, by Julian Seward et al.
==9853== Using Valgrind-3.15.0 and LibVEX; rerun with -h for copyright info
==9853== Command: ./memory
==9853== 
^C==9853== 
==9853== Process terminating with default action of signal 2 (SIGINT)
==9853==    at 0x4EFC840: __nanosleep_nocancel (in /usr/lib64/libc-2.17.so)
==9853==    by 0x4EFC6F3: sleep (in /usr/lib64/libc-2.17.so)
==9853==    by 0x400584: main (in /root/memory)
==9853== 
==9853== HEAP SUMMARY:
==9853==     in use at exit: 22,528,000 bytes in 22 blocks
==9853==   total heap usage: 22 allocs, 0 frees, 22,528,000 bytes allocated
==9853== 
<b>==9853== 1,024,000 bytes in 1 blocks are still reachable in loss record 1 of 3
==9853==    at 0x4C29F73: malloc (vg_replace_malloc.c:309)
==9853==    by 0x400576: main (in /root/memory)</b>
==9853== 
==9853== 1,024,000 bytes in 1 blocks are possibly lost in loss record 2 of 3
==9853==    at 0x4C29F73: malloc (vg_replace_malloc.c:309)
==9853==    by 0x400576: main (in /root/memory)
==9853== 
==9853== 20,480,000 bytes in 20 blocks are definitely lost in loss record 3 of 3
==9853==    at 0x4C29F73: malloc (vg_replace_malloc.c:309)
==9853==    by 0x400576: main (in /root/memory)
==9853== 
==9853== LEAK SUMMARY:
==9853==    definitely lost: 20,480,000 bytes in 20 blocks
==9853==    indirectly lost: 0 bytes in 0 blocks
==9853==      possibly lost: 1,024,000 bytes in 1 blocks
==9853==    still reachable: 1,024,000 bytes in 1 blocks
==9853==         suppressed: 0 bytes in 0 blocks
==9853== 
==9853== ERROR SUMMARY: 2 errors from 2 contexts (suppressed: 0 from 0)
</pre>