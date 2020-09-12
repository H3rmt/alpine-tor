
# alpine-tor-docker

Alpine based [Tor](https://www.torproject.org/) docker container building [Tor](https://www.torproject.org/) from src. The container can be started as middle(guard)- , bridge- , exit-relay or as proxy exposing only the Socks5 Port per default when running.

  

## Installation

### Pull docker image from dockerhub

  

```

docker pull jfwenisch/alpine-tor

```

### Build docker image manually

  

```

git pull https://github.com/JFWenisch/alpine-tor-docker.git

docker build -t jfwenisch/alpine-tor .

```

  

## Run container 

The alpine-tor container can be started in 4 different modes which can be set via the "mode" environment variable.
Dependent on the chosen node, different ports needs to be opened which are noted in the related section

```

docker run -e mode=${mode} jfwenisch/alpine-tor

```


  

* **Bridge**
  The design of the Tor network means that the IP address of Tor relays is public. However, one of the ways Tor can be blocked by governments or ISPs is by blacklisting the IP addresses of these public Tor nodes. Tor bridges are nodes in the network that are not listed in the public Tor directory, which make it harder for ISPs and governments to block them.

  Bridges are useful for Tor users under oppressive regimes or for people who want an extra layer of security because they're worried somebody will recognize that they are contacting a public Tor relay IP address. Several countries, including China and Iran, have found ways to detect and block connections to Tor bridges. Pluggable transports ([​https://www.torproject.org/docs/pluggable-transports.html.en](https://www.torproject.org/docs/pluggable-transports.html.en)), a special kind of bridge, address this by adding an additional layer of obfuscation.

        
        docker run -e mode=bridge -e ORPort=443 -p 443:443 jfwenisch/alpine-tor
   
    

* **Middle (Guard)**
  A guard is the first relay in the chain of 3 relays building a Tor circuit. A middle relay is neither a guard nor an exit, but acts as the second hop between the two. To become a guard, a relay has to be stable and fast (at least 2MByte/s) otherwise it will remain a middle relay.

  Guard and middle relays usually do not receive abuse complaints. All relays will be listed in the public list of Tor relays, so may be blocked by certain services that don't understand how Tor works or deliberately want to censor Tor users. If you are running a relay from home and have one static IP, you may want to consider running a bridge instead so that your non-Tor traffic doesn't get blocked as though it's coming from Tor. If you have a dynamic IP address or multiple static IPs, this isn't as much of an issue.

  A non-exit Tor relay requires minimal maintenance efforts and bandwidth usage can be highly customized in the tor configuration (will be covered in more detail later in this guide). The so called "exit policy" of the relay decides if it is a relay allowing clients to exit or not. A non-exit relay does not allow exiting in its exit policy.

        
        docker run -e mode=middle -e ORPort=443 -p 443:443 jfwenisch/alpine-tor
       

 * **Exit**
  The exit relay is the final relay in a Tor circuit, the one that sends traffic out its destination. The services Tor clients are connecting to (website, chat service, email provider, etc) will see the IP address of the exit relay instead of their real IP address of the Tor user.
  
   Exit relays have the greatest legal exposure and liability of all the relays. For example, if a user downloads copyrighted material while using your exit relay, you the operator may receive a [​DMCA notice](https://www.dmca.com/Solutions/view.aspx?ID=712f28a5-93f2-467b-ba92-3d58c8345a32&?ref=sol08a2). Any abuse complaints about the exit will go directly to you (via your hoster, depending on the WHOIS records). Generally, most complaints can be handled pretty easily through template letters, which we'll discuss more in legal considerations section.

   Because of the legal exposure that comes with running an exit relay, **you should not run a Tor exit relay from your home**. Ideal exit relay operators are affiliated with some institution, like a university, a library, a hackerspace or a privacy related organization. An institution can not only provide greater bandwidth for the exit, but is better positioned to handle abuse complaints or the rare law enforcement inquiry.

   If you are considering running an exit relay, please read [the section on legal considerations](https://trac.torproject.org/projects/tor/wiki/TorRelayGuide#Legalconsiderationsforexitrelayoperators) for exit relay operators.
  

        
        docker run -e mode=exit  -e DirPort=80 -p 80:80 jfwenisch/alpine-tor

 * **Proxy**
  The node will neither run as exit, bridge or middle and will just connect as client for the usage as proxy

   **Warning:** be extremely careful about sending traffic through tor when not using the tor browser. Any unencrypted traffic will be seen by a potentially malicious exit node. Using any other browser besides tor browser to browse the internet is highly discouraged and will likely not provide any anonymity because your browser will give up your real ip address or enough information to fingerprint you uniquely.

   For more information please refer to the tor [documentation](https://2019.www.torproject.org/docs/documentation.html.en)
  

        
        docker run -e mode=proxy -e SocksPort=9050 -p 9050:9050 jfwenisch/alpine-tor
       


  


## Helm deployment
For the helm chart usage pls refer to alpine-tor https://github.com/JFWenisch/alpine-tor-helm


## Kubernetes deployment
For classic kubernetes deployments pls refer tor For the helm chart usage pls refer to https://github.com/JFWenisch/alpine-tor-kubernetes

## Further information


Tor Project https://www.torproject.org/
Alpine Linux https://alpinelinux.org/
obfs4 - The obfourscator https://gitlab.com/yawning/obfs4
  



