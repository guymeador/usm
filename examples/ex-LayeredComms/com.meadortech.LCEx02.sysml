/* 
 * This file © 2025 by Guy Meador is licensed under Apache-2.0
 * To view a copy of this license, visit https://spdx.org/licenses/Apache-2.0.html
 * SPDX-License-Identifier: Apache-2.0
 */  
 
 package 'com.meadortech.LCEx02'{
	alias DF for 'com.meadortech.DataFields';
	alias LC for 'com.meadortech.LayeredComms';
	alias Protocols for 'com.meadortech.LCToyProtocolStack01';
	
	
	private import 'com.meadortech.DataFields'::**;
	private import 'com.meadortech.LayeredComms'::**;
	private import 'com.meadortech.LCToyProtocolStack01'::**;
	private import SequenceFunctions::**;
	
    part def ExampleSOI {
    	
    	
        part def SysA_BB {
			#_PDU_Port_ appPduPort  : AppPDUPort;
			#_PDU_Port_ tpePduPort  : TransportPDUPort;
			#_PDU_Port_ npePduPort  : NetworkPDUPort;
			#_PDU_Port_ dpeaPduPort : DataLinkAPDUPort;
        }
        part def SysB_BB {
			#_PDU_Port_ appPduPort  : AppPDUPort;
			#_PDU_Port_ tpePduPort  : TransportPDUPort;
			#_PDU_Port_ npePduPort  : NetworkPDUPort;
			#_PDU_Port_ dpebPduPort : DataLinkBPDUPort;
        }
		part def SysDLConverter_BB {
			#_PDU_Port_ a : DataLinkAPDUPort;
			#_PDU_Port_ b : DataLinkBPDUPort;
		}
		
		// TODO How to specify necessary encapsulations (ex. tcp over ip) for each of tha above ?
		// TODO How to specify complete comms protocol / protocol entity  operation?
		//      For example: the protocol state machine operates in the context of
		//      SAP, SAPCLient, PDUPorts in relation to protocol layers above/below
		       

        part dab : SysDLConverter_BB;
        part s1  : SysA_BB;
        part s2  : SysB_BB;

		#_PDU_Link_ if_app0102 : AppPDULink {end a ::> s1.appPduPort; end b ::> s2.appPduPort;}
		#_DependsOnPDULink_ dependency over0 from if_app0102 to if_tl01;
		#_Over_PDU_Link_ over_app0102_tl01 {end upper ::> if_app0102; end lower ::> if_tl01;}

        #_PDU_Link_ if_tl01 : TransportLink {end a ::> s1.tpePduPort; end b ::> s2.tpePduPort;}
        #_DependsOnPDULink_ dependency over1 from if_tl01 to if_ic;
        
        #_PDU_Link_ if_ic : NetworkLink {end a ::> s1.npePduPort;end b ::> s2.npePduPort;} 
        #_DependsOnPDULink_ dependency over2 from if_ic to if_s1dab;
        #_DependsOnPDULink_ dependency over3 from if_ic to if_s2dab;
        #_Over_PDU_Link_ over_s1dab {end upper ::> if_ic;end lower ::> if_s1dab;}
		#_Over_PDU_Link_ over_s2dab {end upper ::> if_ic;end lower ::> if_s2dab;}
        
        
        #_PDU_Link_ if_s1dab : DataLinkALink {end a ::> s1.dpeaPduPort; end b ::> dab.a;}
        #_PDU_Link_ if_s2dab : DataLinkALink {end a ::> s2.dpebPduPort; end b ::> dab.b;}
    }
    
    
	
}