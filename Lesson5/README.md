# Практическое задание 5

## 1. Скачайте скрипты и запускайте из будучи пользователем root
## 2. Не смотрите содержимое файла, иначе чинить будет не так интенесно
## 3. Загрузите интересующий вас скрипт на вашу виртуалку с linux (scp или winscp вам в помощь)
## 4. Сделайте файл исполняемым (~# chmod +x <script_name>)
## 5. Запустите файл lab1.sh (~#./lab1.sh) Проблема. Пользователь vasya не в может удалить файл trash в home директории. Попробуйте помочь ей с этим

- Проверен стандартные права доступа на файл - проблем не обнаружено;
- Проверены аттрибуты файла - обноружен установленный аттрибут - **immutable**.

### РЕШЕНИЕ:

Удален аттрибут immutable.

    chattr -i /home/vasya/trash

## 6. Запустите файл lab2.sh (~#./lab2.sh) Пользователи жалуются, что не в состоянии анонимно загрузить файл (например /etc/hosts) на FTP сервер в pub директорию. Попробуйте проанализировать проблему и ее решить Для эмуляции подключающихся анонимных клиентов можно использовать утилиту lftp и, находясь на ftp сервере, подключиться на localhost

### 6.1 Проверено наличие проблемы

#### Результат:

ftp-server не отвечает

#### Решение:

- Проверено наличие прослушиваемого порта - порт не прослушивается;
- Проверено состояние сервиса vsftpd - сервис остановлен;
- Запущен сервис vsftpd;
- Проверено наличие проблемы - сервер отвечает, дает возможность просмотра содержимого;
- Проверна возможность записи в папку pub - выдается ошибка;

<pre>
lftp localhost:~> ls
drwxr-xr-x 2 0 0 6 Oct 30 2018 pub
lftp localhost:/> cd pub
lftp localhost:/pub> put /etc/hosts
put: Access failed: 553 Could not create file. (hosts)
</pre>


### 6.2 SELinux переведен в Permessive-mode

<pre>
# setenforce 0
# getenforce
Permissive
</pre>

#### Результат: проблема сохранилась

### 6.3 Изменены права доступа к папке /var/ftp/pub

<pre>
chmod o+w /var/ftp/pub
</pre>

#### Результат: запись в pub произведена успешно

### 6.4 SELinux переведен в Enforcing-mode

<pre>
# setenforce 1
# getenforce
Enforcing
</pre>

#### Результат: проблема проявилась вновь

### 6.5 Проверено содержимое лог-файла /var/log/audit/audit.log на наличие сообщений SELinux;

<pre>
cat /var/log/audit/audit.log | grep AVC
</pre>

**обнаружена запись:**

<pre>
type=AVC msg=audit(1605444703.708:535): avc:  denied  { write } for  pid=57679 comm="vsftpd" name="pub" dev="dm-0" ino=17331688 scontext=system_u:system_r:<b>ftpd_t</b>:s0-s0:c0.c1023 tcontext=system_u:object_r:<b>public_content_t</b>:s0 tclass=dir permissive=0
</pre>

### 6.6 Изменена политика для папки /var/ftp/pub

<pre>
semanage fcontext -a -t public_content_rw_t "/var/ftp/pub(/.*)?"
restorecon /var/ftp/pub
</pre>

**проверен контекст:**

<pre>
# ls -Z 
drwxr-xrwx. root root system_u:object_r:public_content_rw_t:s0 pub
</pre>

**перезагружен ftp-сервер**

<pre>
systemctl restart vsftpd
</pre>

#### Результат: проблема сохранилась

### 6.7 Анализ с использование sealert

- установлен semanage и sealert:
<pre>
  yum install policycoreutils-python
  yum install setroubleshoot-server-3.2.30-8.el7.x86_64 -y
</pre>

- проведен анализ лог-файла /var/log/audit/audit.log

<pre>
sealert -a /var/log/audit/audit.log
</pre>

**получена рекомендация:**

<pre>
*****  Plugin allow_anon_write (53.1 confidence) suggests   ******************

If you want to allow /usr/sbin/vsftpd to be able to write to shared public content
Then you need to change the label on pub to public_content_rw_t, and potentially turn on the allow_httpd_sys_script_anon_write boolean.
Do
# semanage fcontext -a -t public_content_rw_t pub
# restorecon -R -v pub
# setsebool -P allow_ftpd_anon_write 1
</pre>

**выполнены рекомендованные действия**

<pre>
cd /var/ftp/
semanage fcontext -a -t public_content_rw_t pub
restorecon -R -v pub
setsebool -P allow_ftpd_anon_write 1
systemctl restart vsftpd
</pre>

#### Результат: проблема устранена
