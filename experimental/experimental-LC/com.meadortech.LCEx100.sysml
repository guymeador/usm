/* 
 * This file © 2025-2026 by Guy Meador is licensed under Apache-2.0
 * To view a copy of this license, visit https://spdx.org/licenses/Apache-2.0.html
 * SPDX-License-Identifier: Apache-2.0
 */  

package 'com.meadortech.LCEx100'{
    doc 
        /* 
         * This package © 2025-2026 by Guy Meador is licensed under Apache-2.0
         * To view a copy of this license, visit https://spdx.org/licenses/Apache-2.0.html
         * SPDX-License-Identifier: Apache-2.0
         * 
         * See the comment Package_Overview for additional information
         */

    private import 'com.meadortech.LayeredComms'::**;

    package LayeredProtocolsCollection {
        #_LayeredProtocol_ part def APP specializes LayeredProtocol;
        #_LayeredProtocol_ part def IGMP specializes LayeredProtocol;
        #_LayeredProtocol_ part def HTTP specializes LayeredProtocol;
        #_LayeredProtocol_ part def TCP specializes LayeredProtocol;
        #_LayeredProtocol_ part def UDP specializes LayeredProtocol;
        #_LayeredProtocol_ part def IP specializes LayeredProtocol;
    }

    alias LPC for LayeredProtocolsCollection;

    part def Multicast_Stack specializes ProtocolStack{
        :>> protocols [2] = (IGMP, IP);
        #_LayeredProtocol_ part IGMP : LPC::IGMP subsets protocols;
        #_LayeredProtocol_ part IP   : LPC::IP subsets protocols;

        connection ovr1 : LayeredOn {
            end upper ::> IGMP;
            end lower ::> IP;
        }
    }

    part def Simple_Stack specializes ProtocolStack {
        doc
            /* A protocol stack that includes the TCP/IP protocols. */

        :>> protocols : LayeredProtocol [3]  = (HTTP, TCP, IP);

        #_LayeredProtocol_ part HTTP : LPC::HTTP subsets protocols;
        #_LayeredProtocol_ part TCP  : LPC::TCP  subsets protocols;
        #_LayeredProtocol_ part IP   : LPC::IP   subsets protocols;
        
        connection ovr1 : LayeredOn {
            end upper ::> HTTP;
            end lower ::> TCP;
        }			
        connection ovr2 : LayeredOn connect TCP to IP;

    }
    part def SimpleStack2 specializes ProtocolStack {
        doc
            /* A protocol stack that includes the TCP/IP protocols. */

        :>> protocols : LayeredProtocol [4] = (HTTP, TCP, UDP, IP);

        #_LayeredProtocol_ part HTTP : LPC::HTTP subsets protocols;
        #_LayeredProtocol_ part TCP  : LPC::TCP  subsets protocols;
        #_LayeredProtocol_ part UDP  : LPC::UDP  subsets protocols;
        #_LayeredProtocol_ part IP   : LPC::IP   subsets protocols;
    }
    part def SimpleStack2_1 specializes ProtocolStack {
        doc
            /* A protocol stack that includes the TCP/IP protocols. */

        :>> protocols : LayeredProtocol [4] = (HTTP, TCP, UDP, IP);
        
        #_LayeredProtocol_ part HTTP : LPC::HTTP subsets protocols;
        #_LayeredProtocol_ part TCP  : LPC::TCP  subsets protocols;
        #_LayeredProtocol_ part UDP  : LPC::UDP  subsets protocols;
        #_LayeredProtocol_ part IP   : LPC::IP   subsets protocols;

        connection ovr1 : LayeredOn connect upper::>HTTP to lower::>TCP;
        connection ovr2 : LayeredOn connect upper::>TCP to lower::>IP;
        connection ovr3 : LayeredOn connect upper::>UDP to lower::>IP;
    }

    part def AppStack specializes ProtocolStack {
        doc
            /* A protocol stack for an application. */


        :>> protocols : LayeredProtocol [3] = (APP, UDP, IP);
        
        #_LayeredProtocol_ part APP : LPC::APP subsets protocols;
        #_LayeredProtocol_ part UDP : LPC::UDP subsets protocols;
        #_LayeredProtocol_ part IP  : LPC::IP  subsets protocols;

        connection ovr1  : LayeredOn connect upper::>APP to lower::>UDP;
        connection ovr2  : LayeredOn connect upper::>UDP to lower::>IP;
    }
    part def Stack3 specializes ProtocolStack {
        doc
            /* A protocol stack that includes the TCP/IP protocols. */

        :>> protocols : LayeredProtocol [5] = (APP_Stack, HTTP, TCP, UDP, IP);

        #_LayeredProtocol_ part APP_Stack : AppStack subsets protocols;
        bind APP_Stack.UDP = UDP;
        bind APP_Stack.IP  = IP;

        #_LayeredProtocol_ part HTTP : LPC::HTTP subsets protocols;
        #_LayeredProtocol_ part TCP  : LPC::TCP  subsets protocols;
        #_LayeredProtocol_ part UDP  : LPC::UDP  subsets protocols;
        #_LayeredProtocol_ part IP   : LPC::IP   subsets protocols;

        connection ovr1 : LayeredOn connect upper::>HTTP to lower::>TCP;
        connection ovr2 : LayeredOn connect upper::>TCP to lower::>IP;
        connection ovr3 : LayeredOn connect upper::>UDP to lower::>IP;

    }

    port def AppStackPort specializes ProtocolStackPort {
        doc
            /* A port for an application protocol stack. */
        :>> stack : AppStack;
    }

    part def WAN_IP_Stack specializes ProtocolStack {
        doc
            /* A protocol stack for wide area network (WAN) communication. */

        :>> protocols : LayeredProtocol [1] = IP;

        #_LayeredProtocol_ part IP : LPC::IP subsets protocols {}
    }
    port def WAN_IP_StackPort specializes ProtocolStackPort {
        doc
            /* A port for a wide area network (WAN) protocol stack. */
        :>> stack : WAN_IP_Stack;
    }
    interface def AppWAN_Interface {
        doc
            /* An interface between an application protocol stack and a wide area network (WAN) protocol stack. */
        end app : AppStackPort [1];
        end wan : WAN_IP_StackPort [1];
//        connection awIP connect app.stack.IP to wan.stack.IP;
//        connection cip1 : ProtocolStackHConn connect app.stack.IP to wan.stack.IP;
    }
    part def sys1 {
        part a1   {port appPort : AppStackPort;} 
        part wan1 {port wanPort : WAN_IP_StackPort;}
        connection aw1 : AppWAN_Interface connect a1.appPort to wan1.wanPort;
    }

    part def 'App-WAN Protocol Stack' specializes ProtocolStack{
        :>> protocols;

        #_LayeredProtocol_ part APP : LPC::APP subsets protocols;
        #_LayeredProtocol_ part HTTP : LPC::HTTP subsets protocols;
        #_LayeredProtocol_ part TCP  : LPC::TCP  subsets protocols;
        #_LayeredProtocol_ part UDP  : LPC::UDP  subsets protocols;
        #_LayeredProtocol_ part IP   : LPC::IP   subsets protocols;

        connection ovr1 : LayeredOn connect upper::>HTTP to lower::>TCP;
        connection ovr2 : LayeredOn connect upper::>TCP  to lower::>IP;
        connection ovr3 : LayeredOn connect upper::>UDP  to lower::>IP;
        connection ovr4 : LayeredOn connect upper::>APP  to lower::>UDP;

    }

    interface def 'App-WAN Stack' specializes AppWAN_Interface, ProtocolStackInterface{
        part stack :'App-WAN Protocol Stack' redefines ProtocolStackInterface::stack;
        end app redefines AppWAN_Interface::app, ProtocolStackInterface::endA;
        end wan redefines AppWAN_Interface::wan, ProtocolStackInterface::endB;
    }

    part def sys2 {
        part a1   {port appPort : AppStackPort;} 
        part wan1 {port wanPort : WAN_IP_StackPort;}
        connection aw1 : 'App-WAN Stack' connect a1.appPort to wan1.wanPort{
            connection a1ip   : ProtocolStackHConn connect app.stack.IP  to stack.IP;
            connection wan1ip : ProtocolStackHConn connect wan.stack.IP  to stack.IP;
            connection a1udp  : ProtocolStackHConn connect app.stack.UDP to stack.UDP;
            connection a1app  : ProtocolStackHConn connect app.stack.APP to stack.APP;
        }
    }

    part def sys3 {
        part a1   {port appPort : AppStackPort;} 
        part a2   {port appPort : AppStackPort;} 
        part wan1 {
            port wanPortA : WAN_IP_StackPort; 
            port wanPortB : WAN_IP_StackPort;
        }
        connection aw1 : 'App-WAN Stack' connect a1.appPort to wan1.wanPortA{
            connection a1app  : ProtocolStackHConn connect app.stack.APP to stack.APP;
            connection a1udp  : ProtocolStackHConn connect app.stack.UDP to stack.UDP;
            connection a1ip   : ProtocolStackHConn connect app.stack.IP  to stack.IP;
            connection wan1ip : ProtocolStackHConn connect wan.stack.IP  to stack.IP;
        }
        connection aw2 : 'App-WAN Stack' connect a2.appPort to wan1.wanPortB{
            connection a2app  : ProtocolStackHConn connect app.stack.APP to stack.APP;
            connection a2udp  : ProtocolStackHConn connect app.stack.UDP to stack.UDP;
            connection a2ip   : ProtocolStackHConn connect app.stack.IP  to stack.IP;
            connection wan1ip : ProtocolStackHConn connect wan.stack.IP  to stack.IP;
        }
    }

}