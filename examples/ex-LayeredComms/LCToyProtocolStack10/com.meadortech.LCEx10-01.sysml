/* 
 * This file © 2025-2026 by Guy Meador is licensed under Apache-2.0
 * To view a copy of this license, visit https://spdx.org/licenses/Apache-2.0.html
 * SPDX-License-Identifier: Apache-2.0
 */  
 
 package 'com.meadortech.LCEx10-01'{
	alias DF for 'com.meadortech.DataFields';
	alias LC for 'com.meadortech.LayeredComms';
	alias Protocols for 'com.meadortech.LCToyProtocolStack10';
	
	
	private import 'com.meadortech.LayeredComms'::**;
	private import 'com.meadortech.LCToyProtocolStack10'::**;
	
    part def ExampleSOI {
    	
        comment Stack1_Commentary about Stack1
            /* Here is a protocol stack that might be defined to run in a given host on a network.
            Note that this expression is specifying existence of protocol entities and their "vertical" interconnection within the host without selecting an implementation.
            */
        part def Stack1 {
			#_ProtocolEntity_ ap1  : App = new App();
            #_ProtocolEntity_ tpe  : TransportProtocolEntity;
            #_ProtocolEntity_ npe  : NetworkProtocolEntity;
            #_ProtocolEntity_ dpae : DataLinkAProtocolEntity;

            #_SDU_Link_ app_tpe_01 : TransportSDULink {end sapCl::> ap1.tcl;        end sap::> tpe.saps;}
            #_SDU_Link_ tpe_npe_01 : NetworkSDULink   {end sapCl::> tpe.sapClients; end sap::> npe.saps;}
            #_SDU_Link_ npe_dpe_01 : DataLinkASDULink {end sapCL::> npe.sapClients; end sap::> dpae.saps;}
        }
        
        comment Stack2_Commentary about Stack2, Stack1_Commentary
            /* Here is another protocol stack that might be defined to run in a given host on a network.
            See Stack1_Commentary for more explanation.
            */
        part def Stack2 {
			#_ProtocolEntity_ ap2  : App = new App();	    
            #_ProtocolEntity_ tpe  : TransportProtocolEntity;
            #_ProtocolEntity_ npe  : NetworkProtocolEntity;
            #_ProtocolEntity_ dpae : DataLinkAProtocolEntity;

            #_SDU_Link_ app_tpe_02 : TransportSDULink {end sapCl::> ap2.tcl;        end sap::> tpe.saps;}
            #_SDU_Link_ tpe_npe_02 : NetworkSDULink   {end sapCl::> tpe.sapClients; end sap::> npe.saps;}
            #_SDU_Link_ npe_dpe_02 : DataLinkASDULink {end sapCL::> npe.sapClients; end sap::> dpae.saps;}
        }        

        comment about s1, s2, Stack1, Stack2 
            /* Here are two parts using the above definitions. */
        part s1  : Stack1;
        part s2  : Stack2;

        comment about s1, s2, if_app, if_trans, if_net, if_dl
            /* Here, the PDU links between the PDU port of each protocol entity are connected to the peer entity's PDU port (within the same protocol).
            */
		#_PDU_Link_ if_app    : AppPDULink    {end a ::> s1.ap1.pduPort;  end b ::> s2.ap2.pduPort;}
        #_PDU_Link_ if_trans  : TransportLink {end a ::> s1.tpe.pduPort;  end b ::> s2.tpe.pduPort;}
        #_PDU_Link_ if_net    : NetworkLink   {end a ::> s1.npe.pduPort;  end b ::> s2.npe.pduPort;} 
        #_PDU_Link_ if_dl     : DataLinkALink {end a ::> s1.dpae.pduPort; end b ::> s2.dpae.pduPort;}

        comment Using_DependsOnPDULink_ about over0, over1, over2 
            /* Here is one way to show that what is happening on an upper protocol PDU link depends upon a lower protocol PDU link in a given context.
            */
		#_DependsOnPDULink_ dependency over0 from if_app to if_trans;
        #_DependsOnPDULink_ dependency over1 from if_trans to if_net;
        #_DependsOnPDULink_ dependency over2 from if_net to if_dl;

        comment Using_Over_PDU_Link_ about over_a, over_b, over_c
            /* Here is another way to represent that an upper protocol PDU link has a relationship with a lower protocol PDU link. It is another way of representing the general "over" relationship, but this way allows for constraints to be added. Don't become confused that PDUs will be flowing between the related PDU links of different protocols. In a sense, this is "meta" information that is being represented as "non-meta" information in the model.*/

		#_Over_PDU_Link_ over_a {end upper ::> if_app;   end lower ::> if_trans;}
		#_Over_PDU_Link_ over_b {end upper ::> if_trans; end lower ::> if_net  ;}
		#_Over_PDU_Link_ over_c {end upper ::> if_net;   end lower ::> if_dl   ;}
      
        
    }
    
    part def ExWithLinkSet :> ExampleSOI {
	    item exampleLinkSet {
	        members = (if_app, if_trans, if_net, if_dl);
	    }        
    }
    
	
}