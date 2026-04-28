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
        part def APP specializes LayeredProtocol;
        part def IGMP specializes LayeredProtocol;
        part def HTTP specializes LayeredProtocol;
        part def TCP specializes LayeredProtocol;
        part def UDP specializes LayeredProtocol;
        part def IP specializes LayeredProtocol;
    }

    alias LPC for LayeredProtocolsCollection;

    part def Multicast_Stack specializes ProtocolStack{
        :>> protocols [2] = (IGMP, IP);
        part IGMP : LPC::IGMP subsets protocols;
        part IP   : LPC::IP subsets protocols;

        connection ovr1 : LayeredOn {
            end upper ::> IGMP;
            end lower ::> IP;
        }
    }

    part def Simple_Stack specializes ProtocolStack {
        doc
            /* A protocol stack that includes the TCP/IP protocols. */

        :>> protocols : LayeredProtocol [3]  = (HTTP, TCP, IP);

        part HTTP : LPC::HTTP subsets protocols;
        part TCP  : LPC::TCP  subsets protocols;
        part IP   : LPC::IP   subsets protocols;
        
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

        part HTTP : LPC::HTTP subsets protocols;
        part TCP  : LPC::TCP  subsets protocols;
        part UDP  : LPC::UDP  subsets protocols;
        part IP   : LPC::IP   subsets protocols;
    }
    part def SimpleStack2_1 specializes ProtocolStack {
        doc
            /* A protocol stack that includes the TCP/IP protocols. */

        :>> protocols : LayeredProtocol [4] = (HTTP, TCP, UDP, IP);
        
        part HTTP : LPC::HTTP subsets protocols;
        part TCP  : LPC::TCP  subsets protocols;
        part UDP  : LPC::UDP  subsets protocols;
        part IP   : LPC::IP   subsets protocols;

        connection ovr1 : LayeredOn connect upper::>HTTP to lower::>TCP;
        connection ovr2 : LayeredOn connect upper::>TCP to lower::>IP;
        connection ovr3 : LayeredOn connect upper::>UDP to lower::>IP;
    }

    part def AppStack specializes ProtocolStack {
        doc
            /* A protocol stack for an application. */


        :>> protocols : LayeredProtocol [3] = (APP, UDP, IP);
        
        part APP : LPC::APP subsets protocols;
        part UDP : LPC::UDP subsets protocols;
        part IP  : LPC::IP  subsets protocols;

        connection ovr1  : LayeredOn connect upper::>APP to lower::>UDP;
        connection ovr2  : LayeredOn connect upper::>UDP to lower::>IP;
    }
    part def Stack3 specializes ProtocolStack {
        doc
            /* A protocol stack that includes the TCP/IP protocols. */

        :>> protocols : LayeredProtocol [5] = (APP_Stack, HTTP, TCP, UDP, IP);

        part APP_Stack : AppStack subsets protocols;
        bind APP_Stack.UDP = UDP;
        bind APP_Stack.IP  = IP;

        part HTTP : LPC::HTTP subsets protocols;
        part TCP  : LPC::TCP  subsets protocols;
        part UDP  : LPC::UDP  subsets protocols;
        part IP   : LPC::IP   subsets protocols;

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

        part IP : LPC::IP subsets protocols {}
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

        part APP : LPC::APP subsets protocols;
        part HTTP : LPC::HTTP subsets protocols;
        part TCP  : LPC::TCP  subsets protocols;
        part UDP  : LPC::UDP  subsets protocols;
        part IP   : LPC::IP   subsets protocols;

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
    
}