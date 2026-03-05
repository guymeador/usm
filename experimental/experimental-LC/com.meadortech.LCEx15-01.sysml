/* 
 * This file © 2025 by Guy Meador is licensed under Apache-2.0
 * To view a copy of this license, visit https://spdx.org/licenses/Apache-2.0.html
 * SPDX-License-Identifier: Apache-2.0
 */  
 
 package 'com.meadortech.LCEx01'{
	alias DF for 'com.meadortech.DataFields';
	alias LC for 'com.meadortech.LayeredComms';
	alias Protocols for 'com.meadortech.LCToyProtocolStack01';
	
	
	private import 'com.meadortech.DataFields'::**;
	private import 'com.meadortech.LayeredComms'::**;
	private import 'com.meadortech.LCToyProtocolStack01'::**;
	private import SequenceFunctions::**;
	
    part def ExampleSOI {
    	
    	// * TODO Review00001: Consider other approaches to multi-box middle boxes
    	
        part def Stack1 {
			#_ProtocolEntity_ ap1 : App = new App(useTransport = true);
            #_ProtocolEntity_ tpe : TransportProtocolEntity;
            #_ProtocolEntity_ npe : NetworkProtocolEntity;
            #_ProtocolEntity_ dpe : DataLinkAProtocolEntity;

            #_SDU_Link_ app_tpe_01 : TransportSDULink {end sapCl::> ap1.tcl;        end sap::> tpe.saps;}
            #_SDU_Link_ tpe_npe_01 : NetworkSDULink   {end sapCl::> tpe.sapClients; end sap::> npe.saps;}
            #_SDU_Link_ npe_dpe_01 : DataLinkASDULink {end sapCL::> npe.sapClients; end sap::> dpe.saps;}
        }
        
        part def Stack2 {
			#_ProtocolEntity_ ap2 : App = new App(useTransport = true);	    
            #_ProtocolEntity_ tpe : TransportProtocolEntity;
            #_ProtocolEntity_ npe : NetworkProtocolEntity;
            #_ProtocolEntity_ dpe : DataLinkBProtocolEntity;

            #_SDU_Link_ app_tpe_02 : TransportSDULink {end sapCl::> ap2.tcl;        end sap::> tpe.saps;}
            #_SDU_Link_ tpe_npe_02 : NetworkSDULink   {end sapCl::> tpe.sapClients; end sap::> npe.saps;}
            #_SDU_Link_ npe_dpe_02 : DataLinkBSDULink {end sapCL::> npe.sapClients; end sap::> dpe.saps;}
        }        


        part dab : DataLinkABConverter;
        part s1  : Stack1;
        part s2  : Stack2;

		#_PDU_Link_ if_app0102 : AppPDULink {end a ::> s1.ap1.pduPort; end b ::> s2.ap2.pduPort;}
		#_DependsOnPDULink_ dependency over0 from if_app0102 to if_tl01;
		#_Over_PDU_Link_ over_app0102_tl01 {end upper ::> if_app0102; end lower ::> if_tl01;}

        #_PDU_Link_ if_tl01 : TransportLink {end a ::> s1.tpe.pduPort; end b ::> s2.tpe.pduPort;}
        #_DependsOnPDULink_ dependency over1 from if_tl01 to if_ic;
        
        #_PDU_Link_ if_ic : NetworkLink {end a ::> s1.npe.pduPort;end b ::> s2.npe.pduPort;} 
        #_DependsOnPDULink_ dependency over2 from if_ic to if_s1dab;
        #_DependsOnPDULink_ dependency over3 from if_ic to if_s2dab;
        #_Over_PDU_Link_ over_s1dab {end upper ::> if_ic;end lower ::> if_s1dab;}
		#_Over_PDU_Link_ over_s2dab {end upper ::> if_ic;end lower ::> if_s2dab;}
        
        
        #_PDU_Link_ if_s1dab : DataLinkALink {end a ::> s1.dpe.pduPort; end b ::> dab.a;}
        #_PDU_Link_ if_s2dab : DataLinkALink {end a ::> s2.dpe.pduPort; end b ::> dab.b;}
    }
    
    part def ExWithLinkSet :> ExampleSOI {
	    item exampleLinkSet {
	        members = (if_tl01, if_ic, if_s1dab, if_s2dab);
	    }        
    }
    
	
}