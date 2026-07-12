PS C:\WINDOWS\system32> # First, verify IP settings are correct
>> ipconfig /all

Windows IP Configuration

   Host Name . . . . . . . . . . . . : WIN11-CLIENT
   Primary Dns Suffix  . . . . . . . : servercorp.local
   Node Type . . . . . . . . . . . . : Hybrid
   IP Routing Enabled. . . . . . . . : No
   WINS Proxy Enabled. . . . . . . . : No
   DNS Suffix Search List. . . . . . : servercorp.local

Ethernet adapter Ethernet:

   Connection-specific DNS Suffix  . :
   Description . . . . . . . . . . . : Intel(R) PRO/1000 MT Desktop Adapter
   Physical Address. . . . . . . . . : 08-00-27-FC-1D-4E
   DHCP Enabled. . . . . . . . . . . : No
   Autoconfiguration Enabled . . . . : Yes
   Link-local IPv6 Address . . . . . : fe80::73c:e1dd:9712:730f%4(Preferred)
   IPv4 Address. . . . . . . . . . . : 192.168.100.6(Preferred)
   Subnet Mask . . . . . . . . . . . : 255.255.255.0
   Default Gateway . . . . . . . . . : 192.168.100.1
   DHCPv6 IAID . . . . . . . . . . . : 84410407
   DHCPv6 Client DUID. . . . . . . . : 00-01-01-00-31-D3-AB-A7-08-00-27-FC-1D-4E
   DNS Servers . . . . . . . . . . . : 192.168.100.10
   NetBIOS over Tcpip. . . . . . . . : Enabled
PS C:\WINDOWS\system32>
PS C:\WINDOWS\system32> # Second, ping the default gateway
>> Test-Connection -ComputerName 192.168.100.1 -Count 4

Source        Destination     IPV4Address      IPV6Address                              Bytes    Time(ms)
------        -----------     -----------      -----------                              -----    --------
WIN11-CLIENT  192.168.100.1                                                             32       0
WIN11-CLIENT  192.168.100.1                                                             32       0
WIN11-CLIENT  192.168.100.1                                                             32       0
WIN11-CLIENT  192.168.100.1                                                             32       0


PS C:\WINDOWS\system32> # Third, ping the domain controller
>> Test-Connection -ComputerName 192.168.100.10 -Count 4

Source        Destination     IPV4Address      IPV6Address                              Bytes    Time(ms)
------        -----------     -----------      -----------                              -----    --------
WIN11-CLIENT  192.168.100.10  192.168.100.10                                            32       1
WIN11-CLIENT  192.168.100.10  192.168.100.10                                            32       5
WIN11-CLIENT  192.168.100.10  192.168.100.10                                            32       0
WIN11-CLIENT  192.168.100.10  192.168.100.10                                            32       0


PS C:\WINDOWS\system32> # Fourth, verify DNS is resolving correctly
>> Resolve-DnsName servercorp.local
>> Resolve-DnsName google.com

Name                                           Type   TTL   Section    IPAddress
----                                           ----   ---   -------    ---------
servercorp.local                               A      600   Answer     192.168.100.10
google.com                                     AAAA   112   Answer     2607:f8b0:4023:1804::71
google.com                                     AAAA   112   Answer     2607:f8b0:4023:1804::8b
google.com                                     AAAA   112   Answer     2607:f8b0:4023:1804::66
google.com                                     AAAA   112   Answer     2607:f8b0:4023:1804::64
google.com                                     A      48    Answer     142.250.137.100
google.com                                     A      48    Answer     142.250.137.113
google.com                                     A      48    Answer     142.250.137.139
google.com                                     A      48    Answer     142.250.137.101
google.com                                     A      48    Answer     142.250.137.102
google.com                                     A      48    Answer     142.250.137.138


PS C:\WINDOWS\system32> # Fifth, Check adapter status
>> Get-NetAdapter | Select-Object Name, Status, LinkSpeed
>>
>> # Also, checking for any disabled adapters
>> Get-NetAdapter | Where-Object {$_.Status -eq "Disabled"}

Name     Status LinkSpeed
----     ------ ---------
Ethernet Up     1 Gbps


PS C:\WINDOWS\system32> # Clear DNS cache
>> Clear-DnsClientCache
>> Write-Host "DNS cache cleared"
DNS cache cleared
PS C:\WINDOWS\system32>
PS C:\WINDOWS\system32> #lastly, reset network stack
>> netsh int ip reset
>> netsh winsock reset
>> Write-Host "Network stack reset successfuly"
>> Write-Host "Restart required to complete reset"
