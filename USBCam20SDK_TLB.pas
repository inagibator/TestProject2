unit USBCam20SDK_TLB;

// ************************************************************************ //
// WARNING                                                                    
// -------                                                                    
// The types declared in this file were generated from data read from a       
// Type Library. If this type library is explicitly or indirectly (via        
// another type library referring to this type library) re-imported, or the   
// 'Refresh' command of the Type Library Editor activated while editing the   
// Type Library, the contents of this file will be regenerated and all        
// manual modifications will be lost.                                         
// ************************************************************************ //

// $Rev: 17244 $
// File generated on 28.06.2013 5:20:18 from Type Library described below.

// ************************************************************************  //
// Type Lib: D:\cmsdemo3018\_USBCam20SDK.tlb (1)
// LIBID: {247CDFB1-8C97-4E68-AE8A-8F8EA70B75AA}
// LCID: 0
// Helpfile: 
// HelpString: USBCam20SDK 1.0 Type Library
// DepndLst: 
//   (1) v2.0 stdole, (C:\Windows\system32\stdole2.tlb)
// ************************************************************************ //
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers. 
{$WARN SYMBOL_PLATFORM OFF}
{$WRITEABLECONST ON}
{$VARPROPSETTER ON}
{$ALIGN 4}
interface

uses Windows, ActiveX, Classes, Graphics, OleServer, StdVCL, Variants;
  

// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:        
//   Type Libraries     : LIBID_xxxx                                      
//   CoClasses          : CLASS_xxxx                                      
//   DISPInterfaces     : DIID_xxxx                                       
//   Non-DISP interfaces: IID_xxxx                                        
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  USBCam20SDKMajorVersion = 1;
  USBCam20SDKMinorVersion = 0;

  LIBID_USBCam20SDK: TGUID = '{247CDFB1-8C97-4E68-AE8A-8F8EA70B75AA}';

  IID_ICamera: TGUID = '{B4B6863D-16D9-45BE-9086-FE6439631891}';
  CLASS_CCamera: TGUID = '{BDBABB31-5B48-4E75-8B3A-2028AE335304}';
  CLASS_CCameraProps: TGUID = '{87A15845-47D7-4372-A0F4-7C0CA95B8222}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  ICamera = interface;
  ICameraDisp = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  CCamera = ICamera;
  CCameraProps = IUnknown;


// *********************************************************************//
// Interface: ICamera
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {B4B6863D-16D9-45BE-9086-FE6439631891}
// *********************************************************************//
  ICamera = interface(IDispatch)
    ['{B4B6863D-16D9-45BE-9086-FE6439631891}']
    function Get_WhiteBalance: LongWord; safecall;
    procedure Set_WhiteBalance(pVal: LongWord); safecall;
    function Get_ShutterMode: LongWord; safecall;
    procedure Set_ShutterMode(pVal: LongWord); safecall;
    function IsButtonPressed: WordBool; safecall;
    function Get_EnhancedMotion: LongWord; safecall;
    procedure Set_EnhancedMotion(pVal: LongWord); safecall;
    property WhiteBalance: LongWord read Get_WhiteBalance write Set_WhiteBalance;
    property ShutterMode: LongWord read Get_ShutterMode write Set_ShutterMode;
    property EnhancedMotion: LongWord read Get_EnhancedMotion write Set_EnhancedMotion;
  end;

// *********************************************************************//
// DispIntf:  ICameraDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {B4B6863D-16D9-45BE-9086-FE6439631891}
// *********************************************************************//
  ICameraDisp = dispinterface
    ['{B4B6863D-16D9-45BE-9086-FE6439631891}']
    property WhiteBalance: LongWord dispid 1;
    property ShutterMode: LongWord dispid 2;
    function IsButtonPressed: WordBool; dispid 3;
    property EnhancedMotion: LongWord dispid 4;
  end;

// *********************************************************************//
// The Class CoCCamera provides a Create and CreateRemote method to          
// create instances of the default interface ICamera exposed by              
// the CoClass CCamera. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoCCamera = class
    class function Create: ICamera;
    class function CreateRemote(const MachineName: string): ICamera;
  end;

// *********************************************************************//
// The Class CoCCameraProps provides a Create and CreateRemote method to          
// create instances of the default interface IUnknown exposed by              
// the CoClass CCameraProps. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoCCameraProps = class
    class function Create: IUnknown;
    class function CreateRemote(const MachineName: string): IUnknown;
  end;

implementation

uses ComObj;

class function CoCCamera.Create: ICamera;
begin
  Result := CreateComObject(CLASS_CCamera) as ICamera;
end;

class function CoCCamera.CreateRemote(const MachineName: string): ICamera;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_CCamera) as ICamera;
end;

class function CoCCameraProps.Create: IUnknown;
begin
  Result := CreateComObject(CLASS_CCameraProps) as IUnknown;
end;

class function CoCCameraProps.CreateRemote(const MachineName: string): IUnknown;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_CCameraProps) as IUnknown;
end;

end.
