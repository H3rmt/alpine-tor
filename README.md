Bridge compose.yml
```yaml
version: "3.4"
services:
  obfs4-bridge:
    image: thetorproject/obfs4-bridge:latest
    restart: unless-stopped
    container_name: bridge
    user: "0:0"
    environment:
      - mode=bridge
      - ORPort=9001
      - PTPort=8000
      - ContactInfo=---
      - AccountingStart="week 1 01:00"
      - AccountingMax="2 TBytes"
    volumes:
      - /data:/var/lib/tor
    network_mode: host
```

Middle compose.yml
```yaml
version: "3.4"
services:
  obfs4-bridge:
    image: thetorproject/obfs4-bridge:latest
    restart: unless-stopped
    container_name: middle
    user: "0:0"
    environment:
      - mode=middle
      - ORPort=9001
      - ContactInfo=---
      - AccountingStart="week 1 01:00"
      - AccountingMax="2 TBytes"
    volumes:
      - /data:/var/lib/tor
    network_mode: host
```

Exit compose.yml
```yaml
version: "3.4"
services:
  obfs4-bridge:
    image: thetorproject/obfs4-bridge:latest
    restart: unless-stopped
    container_name: exit
    user: "0:0"
    environment:
      - mode=exit
      - ORPort=9001
      - DirPort=---
      - ContactInfo=---
      - AccountingStart="week 1 01:00"
      - AccountingMax="2 TBytes"
    volumes:
      - /data:/var/lib/tor
    network_mode: host
```