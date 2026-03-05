/* 
 * This file © 2025 by Guy Meador is licensed under Apache-2.0
 * To view a copy of this license, visit https://spdx.org/licenses/Apache-2.0.html
 * SPDX-License-Identifier: Apache-2.0
 */  
 
 package 'com.meadortech.LCToyProtocolStack01'{

	alias DF for 'com.meadortech.DataFields';
	alias DFT for 'com.meadortech.DFNumerics';
	alias LC for 'com.meadortech.LayeredComms';
    alias NP for NetworkProtocol;


	private import 'com.meadortech.LayeredComms'::**;
	
	
	// Common for the stack
	
    item def NetworkAddress :> DFT::Word128;

	package TransportProtocol {   
     	@ProtocolPackage{protocolName="Transport";}
	    
	    #_ProtocolEntity_ def TransportProtocolEntity  {
	    	protocolName = "Transport";
	    	
	        #_SAP_          saps        : TransportSAP         [1] redefines saps;
	        #_PDU_Port_     pduPort     : TransportPDUPort     [1] redefines pduPorts;
	        #_SAP_Client_   sapClients  : NP::NetworkSAPClient [1] redefines sapClients;
	        #_Protocol_Stm_ protocolStm : TransportProtocolStm [1] redefines protocolStm;
	        
	        #_Protocol_Stm_ def TransportProtocolStm;
	    }
	
		//// PDU-related
		    
	    #_PDU_ def TransportPDU {
	     	protocolName="Transport";
	    }
	
	    #_PDU_Port_ def TransportPDUPort {
	    	protocolName = "Transport";
	        inout #_PDU_ io_pdu : TransportPDU redefines io_pdu;
	    }
	
	    #_PDU_Link_ def TransportLink  {
	     	protocolName="Transport";
	        end #_PDU_Port_ a : TransportPDUPort redefines a;
	        end #_PDU_Port_ b : TransportPDUPort redefines b;
	        flow f_ab of abPDU : TransportPDU from a.io_pdu to b.io_pdu;
	        flow f_ba of abPDU : TransportPDU from b.io_pdu to a.io_pdu;
	    }
	
		//// SAP-related
		
		item def TransportPortNumber :> DFT::Word64;
		
		enum def TransportWellKnownPortNumbers :> DFT::Natural64{
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
	    
	    #_SDU_ def TransportSDU {protocolName="Transport";}
	
		#_SDU_ def SigTransportOpen specializes TransportSDU{
	    	item       localPort     : TransportPortNumber;
	    	item       remoteSocket  : TransportSocket;
	    	attribute  activePassive : ActivePassive;
		}
		
		#_SDU_ def SigTransportClose specializes TransportSDU;
	
	    #_SDU_ def SigByteStreamData specializes TransportSDU{
	        item buffer : DF::Octets;
	    }
	    #_SDU_ def SigTransportReceive specializes SigByteStreamData;
	    #_SDU_ def SigTransportSend    specializes SigByteStreamData;
	    
	    ///// Action-based interactions "SDUs"
	    abstract action def TransportOpen {
	    	in localPort     : TransportPortNumber;
	    	in remoteSocket  : TransportSocket;
	    	in activePassive : ActivePassive;
	    	out ref tsap : TSAP;
	    }
	
		abstract action def TransportClose;
			   
	
	    #_SAP_ def <TSAP> TransportSAP {
	    	protocolName="Transport";
	    	ref   actOpen   : TransportOpen;
	    	ref   actClose  : TransportClose;
	    	in    #_SDU_ i_open    : SigTransportOpen;
	    	in    #_SDU_ i_close   : SigTransportClose;
	        in    #_SDU_ i_send    : SigByteStreamData;
	        out   #_SDU_ o_receive : SigByteStreamData;
	    }
	    
	    #_SAP_Client_ def <TSAPClient> TransportSAPClient {
	    	protocolName="Transport";
	    	in    #_SDU_ o_open    : SigTransportOpen;
	    	in    #_SDU_ o_close   : SigTransportClose;
	        in    #_SDU_ o_send    : SigByteStreamData;
	        out   #_SDU_ i_receive : SigByteStreamData;
	    }
	
	    #_SDU_Link_ def TransportSDULink {
	    	protocolName="Transport";
	        end #_SAP_Client_ sapCl : TransportSAPClient [1] redefines sapCl;
	        end #_SAP_ sap   : TransportSAP [1]      redefines sap;
	        flow f_open    of sigOpen     : SigTransportOpen    from sapCl.o_open  to sap.i_open;
	        flow f_close   of sigClose    : SigTransportClose   from sapCl.o_close to sap.i_close;
	        flow f_send    of sigSend     : SigTransportSend    from sapCl.o_send  to sap.i_send;
	        flow f_receive of sigReceive  : SigTransportReceive from sap.o_receive to sapCl.i_receive;
	    }
	

	}

	package NetworkProtocol {   
     	@ProtocolPackage{protocolName="Network";}

	    #_PDU_ def NetworkPDU;
	    
	    #_PDU_Port_ def NetworkPDUPort {
	        inout #_PDU_ io_pdu : NetworkPDU redefines io_pdu;
	    }
	
	    enum def NetProtocol :> ScalarValues::Natural{
	    	enum NET_MGMT = 0;
	    	enum TRANSPORT = 1;
	    }
	
		item def SigNetworkDatagramData{
			item buffer : DF::Octets;
		}
		
		item def SigNetworkOpen{
			item      dstAddr  : NetworkAddress;
			attribute protocol : NetProtocol;
		}
		
		#_SAP_Client_ def NetworkSAPClient; 
		#_SAP_        def NetworkSAP;
		#_SDU_        def NetworkSDU;
	    
	    // * TODO Review00001: Add datalink sap client
	    #_ProtocolEntity_ def NetworkProtocolEntity {
	    	#_SAP_      saps    : NetworkSAP     [1] redefines saps;
	        #_PDU_Port_ pduPort : NetworkPDUPort [1] redefines pduPorts;
	    }
	    #_PDU_Link_ def NetworkLink {
	        end #_PDU_Port_ a : NetworkPDUPort redefines a;
	        end #_PDU_Port_ b : NetworkPDUPort redefines b;        
	        flow f_ab of abPDU : NetworkPDU from a.io_pdu to b.io_pdu;
	        flow f_ba of abPDU : NetworkPDU from b.io_pdu to a.io_pdu;
	    }
	    
	    #_SDU_Link_ def NetworkSDULink {
	    	end #_SAP_Client_ sapCl : NetworkSAPClient [1] redefines sapCl;
	    	end #_SAP_        sap : NetworkSAP [1] redefines sap; 
	    }
	}    

    // Multiple DataLink Layer Protocols

	package DataLinkProtocolA {
     	@ProtocolPackage{protocolName="DatalinkA";}

	    #_ProtocolEntity_ def DataLinkAProtocolEntity {
	    	protocolName="DataLinkA";
	        #_PDU_Port_ pduPort : DataLinkAPDUPort [1] redefines pduPorts;
	    }

	    #_PDU_ def DataLinkAPDU{protocolName="DataLinkA";}
	    
	    
	    #_PDU_Port_ def DataLinkAPDUPort {
	    	protocolName="DataLinkA";
	        inout #_PDU_ io_pdu : DataLinkAPDU redefines io_pdu;
	    }
	    #_PDU_Link_ def DataLinkALink {
	    	protocolName="DataLinkA";
	        end #_PDU_Port_ a : DataLinkAPDUPort redefines a;
	        end #_PDU_Port_ b : DataLinkAPDUPort redefines b;        
	        flow f_ab of abPDU : DataLinkAPDU from a.io_pdu to b.io_pdu;
	        flow f_ba of abPDU : DataLinkAPDU from b.io_pdu to a.io_pdu;
	    }
	    
	    #_SDU_        def DataLinkASDU {protocolName="DataLinkA";}
	    #_SAP_        def DataLinkASAP {protocolName="DataLinkA";}
	    #_SAP_Client_ def DataLinkASAPClient {protocolName="DataLinkA";}
		#_SDU_Link_   def DataLinkASDULink {
	    	protocolName="DataLinkA";
			end #_SAP_Client_ sapCl : DataLinkASAPClient [1] redefines sapCl;
	    	end #_SAP_        sap   : DataLinkASAP       [1] redefines sap; 
		}
		
	}
	
	package DataLinkProtocolB {
     	@ProtocolPackage{protocolName="DatalinkB";}

	    #_ProtocolEntity_ def DataLinkBProtocolEntity {
	    	protocolName="DataLinkB";
	        #_PDU_Port_ pduPort : DataLinkBPDUPort [1] redefines pduPorts;
	    }
	    
	    #_PDU_ def DataLinkBPDU;
	    #_PDU_Port_ def DataLinkBPDUPort;
	    #_PDU_Link_ def DataLinkBLink {
	        end #_PDU_Port_ a : DataLinkBPDUPort redefines a;
	        end #_PDU_Port_ b : DataLinkBPDUPort redefines b;        
	        flow f_ab of abPDU : DataLinkBPDU from a.io_pdu to b.io_pdu;
	        flow f_ba of abPDU : DataLinkBPDU from b.io_pdu to a.io_pdu;
	    }
	    
	    #_SDU_        def DataLinkBSDU {protocolName="DataLinkB";}
	    #_SAP_        def DataLinkBSAP {protocolName="DataLinkB";}
	    #_SAP_Client_ def DataLinkBSAPClient {protocolName="DataLinkB";}
		#_SDU_Link_   def DataLinkBSDULink {
	    	protocolName="DataLinkB";
			end #_SAP_Client_ sapCl : DataLinkBSAPClient [1] redefines sapCl;
	    	end #_SAP_        sap   : DataLinkBSAP       [1] redefines sap; 
		}
	}

	package DataLinkProtocolConversion
	 {

	    part def DataLinkABConverter {
	        #_PDU_Port_ a : DataLinkProtocolA::DataLinkAPDUPort;
	        #_PDU_Port_ b : DataLinkProtocolB::DataLinkBPDUPort;
	    }
	    
	    interface def DataLinkABLink :> DataLinkABConverter;
	    
	    // TODO Add an nterface way of achieving this capability as well
	    
    }
    
    // Some Application
    // * TODO Review00001: Consider a simpler example not using optionality for in-layer
    package AppX {
    	
    	
    	#_PDU_ def AppPDU specializes DF::ExactlyPackedField{
    		
    	}
    	
		#_PDU_Port_ def AppPDUPort :> PDUPort {
	      	inout io_pdu : AppPDU redefines io_pdu;
	    }

	    #_PDU_Link_ def AppPDULink {
	        end #_PDU_Port_ a : AppPDUPort redefines a;
	        end #_PDU_Port_ b : AppPDUPort redefines b;        
	        flow f_ab of abPDU : AppPDU from a.io_pdu to b.io_pdu;
	        flow f_ba of abPDU : AppPDU from b.io_pdu to a.io_pdu;
	    }
  
		action def GenerateAppPDUs{
			out #_PDU_ o_apdu : AppPDU;
		}
		action def ConsumeAppPDUs{
			in #_PDU_ i_apdu : AppPDU;
		}

	    action def ReceiveOctets{
	    	out #_PDU_ o_apdu : AppPDU;
	    	in  i_trcv : TransportProtocol::SigTransportReceive;
	    }
	    action def SendOctets{
	    	in  #_PDU_ i_apdu  : AppPDU;
	    	out o_tsend : TransportProtocol::SigTransportSend;
	    }
	    // * TODO Review0001: Change names to OperateAppLayerVirtually, OperateOverTransport
	    action def OperateAppLayerOnly {
	    	in ref #_PDU_Port_ pduPort : AppPDUPort;

			action def SendAppPDUsInLayer{
				in #_PDU_ i_apdu : AppPDU;
				in ref #_PDU_Port_ pduPort : AppPDUPort;
				
				send i_apdu via pduPort.io_pdu;
				// TODO does the above line achieve the desired effect?
				// TODO Unit Case?
			}

	    	first
	    	start;
	    	
	    	then
	    	fork fork1;
	    		then generatePDUs;
		    	then consumePDUs;
	    		then sendAppPDUs;

	    		action generatePDUs : GenerateAppPDUs;    then join1;
		    	action consumePDUs  : ConsumeAppPDUs;     then join1;
		    	action sendAppPDUs  : SendAppPDUsInLayer; then join1; 	

	    	join join1; 
	    	then done;	

	    	flow apduOut from generatePDUs.o_apdu to sendAppPDUs.i_apdu;
			flow apduIn from pduPort.io_pdu	to consumePDUs.i_apdu;
	    	
	    	
	    }
	    action def OperateWithTransportLayer {
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
	    	
			flow f1 of p : AppPDU from receivePDUs.o_apdu to consumePDUs.i_apdu;
	    	flow generatePDUs.o_apdu to sendPDUs.i_apdu;
			flow sendPDUs.o_tsend to tcl.o_send;
	    	
//			bind sendPDUs.o_tsend = tcl.o_send;
			flow receivePDUs.o_apdu to consumePDUs.i_apdu;
//			bind tcl.i_receive = receivePDUs.i_trcv;
			flow tcl.i_receive to receivePDUs.i_trcv;
	    	
	    }
    	
	    #_ProtocolEntity_ def App{
	    	in useTransport : ScalarValues::Boolean default false;
	    	
	    	#_PDU_Port_   pduPort : AppPDUPort;
	    	#_SAP_Client_ tcl     : TransportProtocol::TransportSAPClient;
	    	
	    	bind operating.tcl     = tcl;
	    	bind operating.pduPort = pduPort;

			exhibit state operating{
				in ref tcl     : TransportProtocol::TransportSAPClient;
				in ref pduPort : AppPDUPort;
				
				bind multiLayerMode.operateWithTransport.tcl = tcl;					
				bind singleLayerMode.operateAppLayerOnly.pduPort = pduPort;					
				
				state init;
				
				state multiLayerMode{
					do action operateWithTransport : OperateWithTransportLayer;
				}

				state singleLayerMode{
					do action operateAppLayerOnly : OperateAppLayerOnly;
				}

				entry; 
				then init;
				
				transition trans_i_m
					first init
					if useTransport == true
					then multiLayerMode;

				transition trans_i_s
					first init					
					if useTransport == false
					then singleLayerMode;
					
				transition trans_m_d
					first multiLayerMode
					then done;

				transition trans_s_d
					first singleLayerMode
					then done;
			}
	    	
	    }
    }

}