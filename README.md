DNS, with integrated ad blocking
---

This is my fork of `oznu/dns-ad-blocker`'s docker container, which is
excellent, but didn't fix my exact use case. I wanted to self-host my own DNS so
that I could route custom local host names to my internal network IP addresses,
while also blocking advertisement domains.

This container uses the latest Alpine linux build, along with the latest stable
`dnsmasq` DNS daemon. Every 24 hours, it will re-fetch ad block list from the
well known [StevenBlack/hosts](https://github.com/StevenBlack/hosts) advertising
server list, and load them into the daemon.

Unlike the original `oznu/dns-ad-blocker` container, this one uses the latest
Alpine builds, uses the block lists direct from Steven Black, and also munges
the block list into a secondary form to additionally block IPv6 addresses, which
are used in some situations to try to bypass these types of blocking systems.

## Usage

```
docker run -d --restart=always -p 53:53/tcp -p 53:53/udp abcminiuser/dns-ad-blocker
```

After starting the container, direct your network clients (usually via your DHCP
server, generally located on your router) to use this container as their primary
DNS server.

Note that because of the way this container works, you *must* use the
[restart policy](https://docs.docker.com/engine/reference/run/#restart-policies---restart)
to ensure the container is automatically restarted every 24 hours when the
update script kills of the daemon.

### Options

To enable logging of DNS queries set ```DEBUG=1```:

```
docker run -d --restart=always -p 53:53/tcp -p 53:53/udp -e "DEBUG=1" abcminiuser/dns-ad-blocker
```

For verbose logging (including source IP address) set ```DEBUG=2```.


By default this image forwards DNS requests for unknown zones to Google's DNS
servers, 8.8.8.8 and 8.8.4.4. You can set your own if required:

```
docker run -d --restart=always -p 53:53/tcp -p 53:53/udp -e "NS1=192.168.0.1" -e "NS2=192.168.0.2" abcminiuser/dns-ad-blocker
```

To disable automatic updates set ```AUTO_UPDATE=0```:

```
docker run -d --restart=always -p 53:53/tcp -p 53:53/udp -e "AUTO_UPDATE=0" abcminiuser/dns-ad-blocker
```

## Ad Blocking

This image is using the blacklists created by
[StevenBlack/hosts](https://github.com/StevenBlack/hosts).

The DNS server works by returning ```0.0.0.0``` when a DNS lookup is made by a
browser or device to a blacklisted domain. ```0.0.0.0``` is defined as a
non-routable meta-address used to designate an invalid, unknown, or non
applicable target which results in the browser rejecting the request.

## Custom Domain Entries

This image supports adding additional zones that may be used to serve internal DNS zones or to override existing zones.

To do this create a volume share when creating the container:

```
docker run -d -p 53:53/tcp -p 53:53/udp -v /srv/zones:/etc/dnsmasq.d/ oznu/dns-ad-blocker
```

Every file in the ```/srv/zones``` will be included as an extension to the Dnsmasq config.

Example:

```
# Add domains which you want to force to an IP address here.
# The example below send any host in doubleclick.net to a local
# webserver.
address=/doubleclick.net/127.0.0.1

# Return an MX record named "maildomain.com" with target
# servermachine.com and preference 50
mx-host=maildomain.com,servermachine.com,50
```

After adding or updating a zone config file you must restart the container for it to be loaded.

## Docker Compose

Example compose configuration:

```
  dns:
    container_name: DNS
    image: abcminiuser/docker-dns-ad-blocker:latest
    network_mode: "host"
    volumes:
      - /volume1/docker/DNS:/etc/dnsmasq.d/
    ports:
      - "53:53/tcp"
      - "53:53/udp"
    environment:
      - DEBUG=2
      - TZ=Australia/Melbourne
    restart: unless-stopped
```

## Credits

As mentioned, this is a lightly modified version of the container by
`oznu/dns-ad-blocker` - all credits to him.
