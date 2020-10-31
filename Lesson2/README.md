## Практическое задание 2

### 1. Скачайте архив в котором файл lesson2.sh
### 2. Не смотрите содержимое файла, иначе чинить будет не так интенесно
### 3. Загрузите файл на вашу виртуалку с linux (scp или winscp вам в помощь)
### 4. Сделайте файл исполняемым (~# chmod +x lesson2.sh)
### 5. Запустите файл от рута (~# ./lesson2.sh)
### 6. Почините сломанный сервис (изменять unit sshd, переустанавливать ssh сервер, создавать новый sshd.service unit нельзя)

#### В unit sshd.service обнаружена зависимость от неустановленного сервиса - vsftpd.

<pre>
[Unit]
Description=OpenSSH server daemon
Documentation=man:sshd(8) man:sshd_config(5)
After=network.target sshd-keygen.service
Wants=sshd-keygen.service
<b>Requisite=vsftpd.service</b>

[Service]
Type=notify
EnvironmentFile=/etc/sysconfig/sshd
ExecStart=/usr/sbin/sshd -D $OPTIONS
ExecReload=/bin/kill -HUP $MAINPID
KillMode=process
Restart=on-failure
RestartSec=42s

[Install]
WantedBy=multi-user.target
</pre>

#### Решение:

Установлен, запущен и "помещен в автозагрузку" сервис vsftpd

<pre>
yum install vsftpd - y
systemctl start vsftpd
systemctl enable vsftpd
</pre>

### 7. Перезагрузите операционную систему и убедитесь, что сервис все еще работает.

После перезагрузки (на самом деле еще при чтении логов) обнаружено, что изменен пароль root.

#### Решение:

- Загрузка с установочного диска в режиме Troubleshoting
- Смена корня файловой системы на /mnt/sysimage

<pre>
chroot /mnt/sysimage
</pre>

- Восстановлен пароль пользователя root

<pre>
passwd root
</pre>

### 8. Сделайте рестарт серввису и убедитесь, что он продолжает работать после рестарта


<pre>
systemctl restart sshd
</pre>

<pre>
[root@localhost ~]# systemctl status sshd

● sshd.service - OpenSSH server daemon
   Loaded: loaded (/usr/lib/systemd/system/sshd.service; enabled; vendor preset: enabled)
   Active: <b>active (running)</b> since Сб 2020-10-31 02:38:08 EDT; 13s ago
     Docs: man:sshd(8)
           man:sshd_config(5)
 Main PID: 1283 (sshd)
   CGroup: /system.slice/sshd.service
           └─1283 /usr/sbin/sshd -D

окт 31 02:38:08 localhost.localdomain systemd[1]: Stopped OpenSSH server daemon.
окт 31 02:38:08 localhost.localdomain systemd[1]: Starting OpenSSH server daemon...
окт 31 02:38:08 localhost.localdomain sshd[1283]: Server listening on 0.0.0.0 port 22.
окт 31 02:38:08 localhost.localdomain sshd[1283]: Server listening on :: port 22.
окт 31 02:38:08 localhost.localdomain systemd[1]: Started OpenSSH server daemon.

</pre>
