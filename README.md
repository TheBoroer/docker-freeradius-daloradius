# Freeradius Server (+ daloRADIUS Web UI) for use with external MySQL Database



## Quick reference
Docker image containing FreeRadius Server (using external mysql database server) + daloRADIUS web interface.

Get the docker container image here: [Docker Hub](https://hub.docker.com/r/boro/freeradius-daloradius)

## Environment Variables

 * `MYSQL_HOST`
    Default: `localhost`
 * `MYSQL_PORT`
    Default: `3306`
 * `MYSQL_DATABASE`
    Default: `radius`
 * `MYSQL_USER`
    Default: `root`
 * `MYSQL_PASS`
    Default: ""
 * `MYSQL_INIT_DATABASE`
    Default: `false`
    If set to `true`, the mysql database will be initialized with default tables/values. BEWARE: If your database is not empty, some tables may be dropped and re-initialized. Recommended use is with a brand new/blank database.
 * `CLIENT_SECRET`
    Radius Secret for client devices
 * `CLIENT_NETx`
    Networks where your radius clients will be connecting from (for example 192.168.0.0/16). `x` should be replaced by a number. Supports adding multiple client IPs/Networks by specifying multiple CLIENT_NETx variables. For example: CLIENT_NET1=192.168.0.0/24 CLIENT_NET2=192.168.100.0/24. If none is specified, the default is set to allowing all IPs to connect: 0.0.0.0/0
  * `CLIENT_MAX_CONNECTIONS`
    Default: `16`
    Limit the number of simultaneous TCP connections from a client (applied to each CLIENT_NETx client). Setting this to 0 means "no limit"
  * `CLIENT_IDLE_TIMEOUT`
    Default: `30`
    The idle timeout, in seconds, of a TCP connection (applied to each CLIENT_NETx client). If no packets have been received over the connection for this time, the connection will be closed. Setting this to 0 means "no timeout".
    It's STRONGLY RECOMMEND that you set an idle timeout.


## Example Usage
```
docker run --name freeradius -d -p 1812:1812/udp -p 1813:1813/udp -p 80:80 \
            -e CLIENT_SECRET=<Radius secret> 
            -e CLIENT_NET1=<client net 1> 
            -e CLIENT_NET2=<client net 2> 
            -e MYSQL_HOST=<MYSQL HOSTNAME OR IP> 
            -e MYSQL_PORT=<MYSQL PORT> 
            -e MYSQL_DATABASE=<MYSQL DATABASE> 
            -e MYSQL_USER=<MYSQL USER> 
            -e MYSQL_PASS=<MYSQL PASSWORD>
            boro/freeradius-daloradius
```


<!-- ## Manage clients nets by web interface
1. Set CLIENT_NETx="" (-e CLIENT_NET1="" -e CLIENT_NET2="" -e CLIENT_NET3="" ...)
2. Manage  devices via web interface -p <addr servers where container run>/mng-rad-nas.php  -->
 
## daloRADIUS Web UI
Default Login for daloRADIUS Web UI.
 * Username: `administrator`
 * Password: `radius`

More Info on daloRADIUS can be found here: [daloRADIUS GitHub](https://github.com/lirantal/daloradius)

## FreeRadius Logs are available through the docker container log:
```
$ docker logs freeradius
```
