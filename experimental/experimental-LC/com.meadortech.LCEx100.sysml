package 'com.meadortech.LCEx100'{

    private import 'com.meadortech.LayeredComms'::**;

    package LayeredProtocolsCollection {
        part def HTTP_LayeredProtocol specializes LayeredProtocol;
        part def TCP_LayeredProtocol specializes LayeredProtocol;
        part def UDP_LayeredProtocol specializes LayeredProtocol;
        part def IP_LayeredProtocol specializes LayeredProtocol;
    }

    alias LPC for LayeredProtocolsCollection;

    part def Simple_Stack specializes ProtocolStack {
        doc
            /* A protocol stack that includes the TCP/IP protocols. */

        :>> protocols : LayeredProtocol [3]  = (HTTP, TCP, IP);

        part HTTP : LPC::HTTP_LayeredProtocol subsets protocols {
            doc
            /* The Hypertext Transfer Protocol (HTTP) layer. */

            :>> over : LayeredProtocol [1]  = TCP;
        }
        connection httpOverTCP : LayeredOn {
            end upper ::> HTTP;
            end lower ::> TCP;
        }			
        part TCP : LPC::TCP_LayeredProtocol subsets protocols {
            doc
            /* The Transmission Control Protocol (TCP) layer. */

            :>> over : LayeredProtocol [1] = IP;
        }
        connection tcpOverIP : LayeredOn connect TCP to IP;

        part IP : LPC::IP_LayeredProtocol subsets protocols {
            doc
            /* The Internet Protocol (IP) layer. */
        }
    }
    part def SimpleStack2 specializes ProtocolStack {
        doc
            /* A protocol stack that includes the TCP/IP protocols. */

        :>> protocols : LayeredProtocol [4] = (HTTP, TCP, UDP, IP);

        part HTTP : LPC::HTTP_LayeredProtocol subsets protocols {:>> over : LayeredProtocol [1] = TCP;}
        part TCP  : LPC::TCP_LayeredProtocol  subsets protocols {:>> over : LayeredProtocol [1] = IP;}
        part UDP  : LPC::UDP_LayeredProtocol  subsets protocols {:>> over : LayeredProtocol [1] = IP;}
        part IP   : LPC::IP_LayeredProtocol   subsets protocols {}
    }
    part def SimpleStack2_1 specializes ProtocolStack {
        doc
            /* A protocol stack that includes the TCP/IP protocols. */

        :>> protocols : LayeredProtocol [4] = (HTTP, TCP, UDP, IP);
        
        part HTTP : LPC::HTTP_LayeredProtocol subsets protocols {:>> over : LayeredProtocol [1] = TCP;}
        part TCP  : LPC::TCP_LayeredProtocol  subsets protocols {:>> over : LayeredProtocol [1] = IP;}
        part UDP  : LPC::UDP_LayeredProtocol  subsets protocols {:>> over : LayeredProtocol [1] = IP;}
        part IP   : LPC::IP_LayeredProtocol   subsets protocols {}

        connection HTTP_Over_TCP : LayeredOn connect upper::>HTTP to lower::>TCP;
        connection TCP_Over_IP   : LayeredOn connect upper::>TCP to lower::>IP;
        connection UDP_Over_IP   : LayeredOn connect upper::>UDP to lower::>IP;
    }

    part def AppStack specializes ProtocolStack {
        doc
            /* A protocol stack for an application. */

        part def APP_LayeredProtocol specializes LayeredProtocol;

        :>> protocols : LayeredProtocol [3] = (APP, UDP, IP);
        
        part APP  : APP_LayeredProtocol       subsets protocols {:>> over : LayeredProtocol [1] = UDP;}
        part UDP  : LPC::UDP_LayeredProtocol  subsets protocols {:>> over : LayeredProtocol [1] = IP;}
        part IP   : LPC::IP_LayeredProtocol   subsets protocols {}

        connection APP_Over_UDP  : LayeredOn connect upper::>APP to lower::>UDP;
        connection UDP_Over_IP   : LayeredOn connect upper::>UDP to lower::>IP;
    }
    part def Stack3 specializes ProtocolStack {
        doc
            /* A protocol stack that includes the TCP/IP protocols. */

        :>> protocols : LayeredProtocol [5] = (APP, HTTP, TCP, UDP, IP);
        part APP : AppStack subsets protocols;
        bind APP.UDP = UDP;
        bind APP.IP  = IP;

        part HTTP : LPC::HTTP_LayeredProtocol subsets protocols {:>> over : LayeredProtocol [1] = TCP;}
        part TCP  : LPC::TCP_LayeredProtocol  subsets protocols {:>> over : LayeredProtocol [1] = IP;}
        part UDP  : LPC::UDP_LayeredProtocol  subsets protocols {:>> over : LayeredProtocol [1] = IP;}
        part IP   : LPC::IP_LayeredProtocol   subsets protocols {}

        connection HTTP_Over_TCP : LayeredOn connect upper::>HTTP to lower::>TCP;
        connection TCP_Over_IP   : LayeredOn connect upper::>TCP to lower::>IP;
        connection UDP_Over_IP   : LayeredOn connect upper::>UDP to lower::>IP;

    }

    abstract port def StackPort {
        doc
            /* A port for a protocol stack. */
        ref stack : ProtocolStack;
    }

    port def AppStackPort specializes StackPort {
        doc
            /* A port for an application protocol stack. */
        :>> stack : AppStack;
    }

    part def WAN_IP_Stack specializes ProtocolStack {
        doc
            /* A protocol stack for wide area network (WAN) communication. */

        :>> protocols : LayeredProtocol [1] = IP;

        part IP   : LPC::IP_LayeredProtocol subsets protocols {}
    }
    port def WAN_IP_StackPort specializes StackPort {
        doc
            /* A port for a wide area network (WAN) protocol stack. */
        :>> stack : WAN_IP_Stack;
    }
    interface def AppWAN_Interface {
        doc
            /* An interface between an application protocol stack and a wide area network (WAN) protocol stack. */
        end app : AppStackPort [1];
        end wan : WAN_IP_StackPort [1];
        connection awIP connect app.stack.IP to wan.stack.IP;
    }
    part def system {
        part a1   {port appPort : AppStackPort;} 
        part wan1 {port wanPort : WAN_IP_StackPort;}
        connection aw1 : AppWAN_Interface connect a1.appPort to wan1.wanPort;
    }	
}