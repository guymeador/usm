/* 
 * This file © 2025-2026 by Guy Meador is licensed under Apache-2.0
 * To view a copy of this license, visit https://spdx.org/licenses/Apache-2.0.html
 * SPDX-License-Identifier: Apache-2.0
 */  
 
 package 'com.meadortech.LCToyProtocolStack10'{
	alias DF for 'com.meadortech.DataFields';
	alias DFT for 'com.meadortech.DFScalarValues';
	alias LC for 'com.meadortech.LayeredComms';
    alias NP for NetworkProtocol;
	private import 'com.meadortech.LayeredComms'::**;
	
	// Common for the stack
	
	item def Octets :> DF::EPF {
		item numoctets : DFT::Word64;
		item b : DFT::Octet [numoctets.value];
	}
    item def NetworkAddress :> DFT::Word128;

	package TransportProtocol {   
     	@ProtocolPackage{protocolName="Transport";}
	    
	    #_ProtocolEntity_ part def TransportProtocolEntity {
	    	protocolName = "Transport";
	    	
	        #_SAP_          port  saps        : TransportSAP         [1] redefines saps;
	        #_PDU_Port_     port  pduPort     : TransportPDUPort     [1] redefines pduPorts;
	        #_SAP_Client_   port  sapClients  : NP::NetworkSAPClient [1] redefines sapClients;
	        #_Protocol_Stm_ state protocolStm : TransportProtocolStm [1] redefines protocolStm;
	        
	        #_Protocol_Stm_ state def TransportProtocolStm;
	    }
	
		//// PDU-related
		    
	    #_PDU_ item def TransportPDU {
	     	protocolName="Transport";
	    }
	
	    #_PDU_Port_ port def TransportPDUPort {
	    	protocolName = "Transport";
	        inout #_PDU_ item io_pdu : TransportPDU redefines io_pdu;
	    }

	    #_PDU_Link_ connection def TransportLink  {
	     	protocolName="Transport";
	        end #_PDU_Port_ port a : TransportPDUPort redefines a;
	        end #_PDU_Port_ port b : TransportPDUPort redefines b;
	        flow f_ab of abPDU : TransportPDU from a.io_pdu to b.io_pdu;
	        flow f_ba of baPDU : TransportPDU from b.io_pdu to a.io_pdu;
	    }
	
		//// SAP-related
		
		item def TransportPortNumber :> DFT::Word64;
		
		enum def TransportWellKnownPortNumbers :> ScalarValues::Natural {
			enum APP = 8080;
		}
		
		item appTN : TransportPortNumber{
			:>> value = TransportWellKnownPortNumbers::APP;
		}
	    
	    item def TransportSocket{
	    	item txPortNum : TransportPortNumber;
	    }
	    
	    enum def ActivePassive {
	    	enum ACTIVE;
	    	enum PASSIVE;
	    }
	    
	    ////// Transport SDUs

	    #_SDU_ item def TransportSDU {protocolName="Transport";}
	
		#_SDU_ item def SigTransportOpen specializes TransportSDU{
	    	item       localPort     : TransportPortNumber;
	    	item       remoteSocket  : TransportSocket;
	    	attribute  activePassive : ActivePassive;
		}

		#_SDU_ item def SigTransportOpenResponse specializes TransportSDU{}
		
		#_SDU_ item def SigTransportClose specializes TransportSDU{}
	
	    #_SDU_ item def SigByteStreamData specializes TransportSDU{
	        item buffer : Octets;
	    }
	    #_SDU_ item def SigTransportReceive specializes SigByteStreamData;
	    #_SDU_ item def SigTransportSend    specializes SigByteStreamData;
	    
	    #_SAP_ port def <TSAP> TransportSAP {
	    	protocolName="Transport";
	    	ref   actOpen   : TransportOpen;
	    	ref   actClose  : TransportClose;
	    	in    #_SDU_ item i_open    : SigTransportOpen;
	    	in    #_SDU_ item i_close   : SigTransportClose;
	        in    #_SDU_ item i_send    : SigByteStreamData;
	        out   #_SDU_ item o_receive : SigByteStreamData;
	    }
	    
	    #_SAP_Client_ port def <TSAPClient> TransportSAPClient {
	    	protocolName="Transport";
	    	out   #_SDU_ item o_open    : SigTransportOpen;
	    	out   #_SDU_ item o_close   : SigTransportClose;
	        out   #_SDU_ item o_send    : SigByteStreamData;
			in    #_SDU_ item i_receive : SigByteStreamData;
	    }
	
	    #_SDU_Link_ connection def TransportSDULink {
	    	protocolName="Transport";
	        end #_SAP_Client_ port sapCl  : TransportSAPClient [1] redefines sapCl;
	        end #_SAP_        port sap    : TransportSAP [1]       redefines sap;
	        flow f_open    of sigOpen     : SigTransportOpen    from sapCl.o_open  to sap.i_open;
	        flow f_close   of sigClose    : SigTransportClose   from sapCl.o_close to sap.i_close;
	        flow f_send    of sigSend     : SigTransportSend    from sapCl.o_send  to sap.i_send;
	        flow f_receive of sigReceive  : SigTransportReceive from sap.o_receive to sapCl.i_receive;
	    }

	    ///// Experimental Action-based interactions "SDUs" ; TODO Complete this work
	    abstract action def TransportOpen {
	    	in      item localPort     : TransportPortNumber;
	    	in      item remoteSocket  : TransportSocket;
	    	in      item activePassive : ActivePassive;
	    	out ref port tsap          : TSAP;
	    }
	
		abstract action def TransportClose;
	}

	package NetworkProtocol {   
     	@ProtocolPackage{protocolName="Network";}

	    #_PDU_ item def NetworkPDU {
	    	protocolName="Network";
	    }
	    
	    #_PDU_Port_ port def NetworkPDUPort {
	        inout #_PDU_ io_pdu : NetworkPDU redefines io_pdu;
	    }
	
	    enum def NetProtocol :> ScalarValues::Natural{
	    	enum NET_MGMT = 0;
	    	enum TRANSPORT = 1;
	    }
	
		item def SigNetworkDatagramData{
			item buffer : Octets;
		}
		
		item def SigNetworkOpen{
			item      dstAddr  : NetworkAddress;
			attribute protocol : NetProtocol;
		}
		
		#_SAP_Client_ port def NetworkSAPClient; 
		#_SAP_        port def NetworkSAP;
		#_SDU_        item def NetworkSDU;
	    
	    // * TODO Review00001: Add datalink sap client
	    #_ProtocolEntity_ part def NetworkProtocolEntity {
	    	protocolName="Network";
	    	#_SAP_      port saps    : NetworkSAP     [1] redefines saps;
	        #_PDU_Port_ port pduPort : NetworkPDUPort [1] redefines pduPorts;
	    }
	    #_PDU_Link_ connection def NetworkLink {
	        end #_PDU_Port_ port a : NetworkPDUPort redefines a;
	        end #_PDU_Port_ port b : NetworkPDUPort redefines b;        
	        flow f_ab of abPDU : NetworkPDU from a.io_pdu to b.io_pdu;
	        flow f_ba of abPDU : NetworkPDU from b.io_pdu to a.io_pdu;
	    }
	    
	    #_SDU_Link_ connection def NetworkSDULink {
	    	end #_SAP_Client_ port sapCl : NetworkSAPClient [1] redefines sapCl;
	    	end #_SAP_        port sap   : NetworkSAP [1]       redefines sap; 
	    }
	}    

    // Multiple DataLink Layer Protocols

	package DataLinkProtocolA {
     	@ProtocolPackage{protocolName="DatalinkA";}

	    #_ProtocolEntity_ part def DataLinkAProtocolEntity {
	    	protocolName="DataLinkA";
	        #_PDU_Port_ pduPort : DataLinkAPDUPort [1] redefines pduPorts;
	    }

	    #_PDU_ item def DataLinkAPDU {protocolName="DataLinkA";}
	    
	    #_PDU_Port_ port def DataLinkAPDUPort {
	    	protocolName="DataLinkA";
	        inout #_PDU_ item io_pdu : DataLinkAPDU redefines io_pdu;
	    }
	    #_PDU_Link_ connection def DataLinkALink {
	    	protocolName="DataLinkA";
	        end #_PDU_Port_ port a : DataLinkAPDUPort redefines a;
	        end #_PDU_Port_ port b : DataLinkAPDUPort redefines b;        
	        flow f_ab of abPDU : DataLinkAPDU from a.io_pdu to b.io_pdu;
	        flow f_ba of abPDU : DataLinkAPDU from b.io_pdu to a.io_pdu;
	    }
	    
	    #_SDU_        item def DataLinkASDU {protocolName="DataLinkA";}
	    #_SAP_        port def DataLinkASAP {protocolName="DataLinkA";}
	    #_SAP_Client_ port def DataLinkASAPClient {protocolName="DataLinkA";}
		#_SDU_Link_   connection def DataLinkASDULink {
	    	protocolName="DataLinkA";
			end #_SAP_Client_ port sapCl : DataLinkASAPClient [1] redefines sapCl;
	    	end #_SAP_        port sap   : DataLinkASAP       [1] redefines sap; 
		}
		
	}
	
	package DataLinkProtocolB {
     	@ProtocolPackage{protocolName="DatalinkB";}

	    #_ProtocolEntity_ part def DataLinkBProtocolEntity {
	    	protocolName="DataLinkB";
	        #_PDU_Port_ port pduPort : DataLinkBPDUPort [1] redefines pduPorts;
	    }
	    
	    #_PDU_ item def DataLinkBPDU {protocolName="DataLinkB";}
	    #_PDU_Port_ port def DataLinkBPDUPort {
	    	protocolName="DataLinkB";
	        inout #_PDU_ item io_pdu : DataLinkBPDU redefines io_pdu;
	    }
	    #_PDU_Link_ connection def DataLinkBLink {
	        end #_PDU_Port_ port a : DataLinkBPDUPort redefines a;
	        end #_PDU_Port_ port b : DataLinkBPDUPort redefines b;        
	        flow f_ab of abPDU : DataLinkBPDU from a.io_pdu to b.io_pdu;
	        flow f_ba of abPDU : DataLinkBPDU from b.io_pdu to a.io_pdu;
	    }
	    
	    #_SDU_        item def DataLinkBSDU {protocolName="DataLinkB";}
	    #_SAP_        port def DataLinkBSAP {protocolName="DataLinkB";}
	    #_SAP_Client_ port def DataLinkBSAPClient {protocolName="DataLinkB";}
		#_SDU_Link_   connection def DataLinkBSDULink {
	    	protocolName="DataLinkB";
			end #_SAP_Client_ sapCl : DataLinkBSAPClient [1] redefines sapCl;
	    	end #_SAP_        sap   : DataLinkBSAP       [1] redefines sap; 
		}
	}

	package DataLinkProtocolConversion{

	    part def DataLinkABConverter {
			doc 
				/* A type of part that converts between the DataLinkA
				 * and DataLinkB protocols.
				 */
	        #_PDU_Port_ port a : DataLinkProtocolA::DataLinkAPDUPort;
	        #_PDU_Port_ port b : DataLinkProtocolB::DataLinkBPDUPort;
	    }
	    
	    connection def DataLinkABLink {
			doc
				/* An interface that is defined to convert between the DataLinkA
				 * and DataLinkB protocols.
				 */
			end #_PDU_Port_ port ea : DataLinkProtocolA::DataLinkAPDUPort;
			end #_PDU_Port_ port eb : DataLinkProtocolB::DataLinkBPDUPort;
		}
	    	    
    }
    
    // Some Application
    package AppX {
    	
    	
    	#_PDU_ item def AppPDU specializes PDU, DF::ExactlyPackedField{
    		
    	}
    	
		#_PDU_Port_ port def AppPDUPort {
	      	inout item io_pdu : AppPDU redefines io_pdu;
	    }

	    #_PDU_Link_ connection def AppPDULink {
	        end #_PDU_Port_ a : AppPDUPort redefines a;
	        end #_PDU_Port_ b : AppPDUPort redefines b;        
	        flow f_ab of abPDU : AppPDU from a.io_pdu to b.io_pdu;
	        flow f_ba of abPDU : AppPDU from b.io_pdu to a.io_pdu;
	    }
  
		action def GenerateAppPDUs{
			out #_PDU_ item o_apdu : AppPDU;
		}
		action def ConsumeAppPDUs{
			in #_PDU_ item i_apdu : AppPDU;
		}

	    action def ReceiveOctets{
	    	in  i_trcv : TransportProtocol::SigTransportReceive;
	    	out #_PDU_ item o_apdu : AppPDU;
	    }
	    action def SendOctets{
	    	in  #_PDU_ item i_apdu  : AppPDU;
	    	out o_tsend : TransportProtocol::SigTransportSend;
	    }
	    action def OperateOverTransport {
	    	in ref tcl : TransportProtocol::TransportSAPClient;

	    	first
	    	start;
	    	
	    	then
	    	fork fork1;
	    		then generatePDUs;
		    	then consumePDUs;
	    		then receivePDUs;
	    		then sendPDUs;
	    		then f1;

	    		action generatePDUs : GenerateAppPDUs; then join1;
		    	action consumePDUs  : ConsumeAppPDUs;  then join1;
		    	action receivePDUs  : ReceiveOctets;   then join1;
		    	action sendPDUs     : SendOctets;	   then join1; 	



	    	join join1; 
	    	then done;	

			// Note that the following may change based on EWG/SWG refinements...

			flow f1 of p : AppPDU from receivePDUs.o_apdu to consumePDUs.i_apdu;
	    	flow generatePDUs.o_apdu to sendPDUs.i_apdu;
			bind sendPDUs.o_tsend = tcl.o_send;
			bind sendPDUs.o_tsend = tcl.o_send;
			bind tcl.i_receive = receivePDUs.i_trcv;
	    	
	    }
    	
	    #_ProtocolEntity_ part def App {
	    	
	    	#_PDU_Port_   port pduPort : AppPDUPort;
	    	#_SAP_Client_ port tcl     : TransportProtocol::TransportSAPClient;
	    	
	    	bind operating.tcl     = tcl;
	    	bind operating.pduPort = pduPort;

			exhibit state operating{
				in ref tcl     : TransportProtocol::TransportSAPClient;
				in ref pduPort : AppPDUPort;
				
				bind multiLayerMode.operateWithTransport.tcl = tcl;					
				
				state init;
				
				state multiLayerMode{
					do action operateWithTransport : OperateOverTransport;
				}

				entry; 
				then init;
				
				transition trans_i_m
					first init
					then multiLayerMode;

				transition trans_m_d
					first multiLayerMode
					then done;

			}
	    	
	    }
    }

}