unit K_CMSCom_TLB;

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

// $Rev: 52393 $
// File generated on 22.04.2022 5:14:38 from Type Library described below.

// ************************************************************************  //
// Type Lib: C:\Delphi_prj\DTmp\CMS_Distr_4.053.00_Morin10N\CMSuite (1)
// LIBID: {3D1CC550-1469-444B-8EAE-7A8F0DAE1F62}
// LCID: 0
// Helpfile:
// HelpString: K_CMSCom Library
// DepndLst:
//   (1) v2.0 stdole, (C:\Windows\SysWOW64\stdole2.tlb)
// SYS_KIND: SYS_WIN32
// ************************************************************************ //
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers.
{$WARN SYMBOL_PLATFORM OFF}
{$WRITEABLECONST ON}
{$VARPROPSETTER ON}
{$ALIGN 4}

interface

uses Winapi.Windows, System.Classes, System.Variants, System.Win.StdVCL, Vcl.Graphics, Vcl.OleServer, Winapi.ActiveX;


// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:
//   Type Libraries     : LIBID_xxxx
//   CoClasses          : CLASS_xxxx
//   DISPInterfaces     : DIID_xxxx
//   Non-DISP interfaces: IID_xxxx
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  K_CMSComMajorVersion = 1;
  K_CMSComMinorVersion = 0;

  LIBID_K_CMSCom: TGUID = '{3D1CC550-1469-444B-8EAE-7A8F0DAE1F62}';

  IID_ID4WCMServer: TGUID = '{5AEF870E-1F9F-4FE6-B342-E4BD0536D149}';
  CLASS_D4WCMServer: TGUID = '{CE130BA0-B2E9-44D6-B326-13E2FCF1BBC9}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary
// *********************************************************************//
  ID4WCMServer = interface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library
// (NOTE: Here we map each CoClass to its Default Interface)
// *********************************************************************//
  D4WCMServer = ID4WCMServer;


// *********************************************************************//
// Interface: ID4WCMServer
// Flags:     (256) OleAutomation
// GUID:      {5AEF870E-1F9F-4FE6-B342-E4BD0536D149}
// *********************************************************************//
  ID4WCMServer = interface(IUnknown)
    ['{5AEF870E-1F9F-4FE6-B342-E4BD0536D149}']
    function SetPatientsInfo(const APatientsInfo: WideString): HResult; stdcall;
    function SetProvidersInfo(const AProvidersInfo: WideString): HResult; stdcall;
    function SetLocationsInfo(const ALocationsInfo: WideString): HResult; stdcall;
    function SetCurContext(APatientID: Integer; AProviderID: Integer; ALocationID: Integer): HResult; stdcall;
    function SetWindowState(AWinState: Integer): HResult; stdcall;
    function SetCurContextEx(APatientID: Integer; AProviderID: Integer; ALocationID: Integer;
                             ATeethRightSet: Integer; ATeethLeftSet: Integer): HResult; stdcall;
    function GetPatientMediaCounter(APatID: Integer; out AMediaCounter: OleVariant): HResult; stdcall;
    function GetWindowHandle(out AWinHandle: OleVariant): HResult; stdcall;
    function SetIniInfo(const AIniInfo: WideString): HResult; stdcall;
    function GetServerInfo(AServerCode: Integer; out AServerInfo: OleVariant): HResult; stdcall;
    function ExecUICommand(AComCode: Integer; const AComInfo: WideString): HResult; stdcall;
    function SetCodePage(ACodePageID: Integer): HResult; stdcall;
    function GetSlidesThumbnails(const AMObjIDs: WideString; AMode: Integer;
                                 out ASThumbs: OleVariant): HResult; stdcall;
    function GetSlidesAttrs(APatID: Integer; AMode: Integer; const AFields: WideString;
                            out ARData: OleVariant): HResult; stdcall;
    function HPSetCurContext(APatientID: Integer; AProviderID: Integer; ALocationID: Integer): HResult; stdcall;
    function HPSetVisibleIcons(const AMObjIDs: WideString; AMode: Integer): HResult; stdcall;
    function HPViewMediaObject(const AViewID: WideString): HResult; stdcall;
    function WGetUserAttrs(const ALogin: WideString; const APassword: WideString;
                           out AUserData: OleVariant): HResult; stdcall;
    function WSetPatientFilter(const ACardNum: WideString; const ASurname: WideString;
                               const AFirstName: WideString; AOrder: Integer; ASelCode: Integer;
                               out APatCount: OleVariant): HResult; stdcall;
    function WGetPatientsData(AStartNum: Integer; ACount: Integer; out AData: OleVariant): HResult; stdcall;
    function WGetMediaTypes(out AData: OleVariant): HResult; stdcall;
    function WSetCurrentPatient(APatientID: Integer): HResult; stdcall;
    function WGetPatObjAttrs(APatientID: Integer; ASelCode: Integer; out AData: OleVariant): HResult; stdcall;
    function WGetSlidesThumbFiles(APatientID: Integer; const ASlideIDs: WideString;
                                  const AThumbPath: WideString): HResult; stdcall;
    function WGetSlideImageFile(ASlideID: Integer; var AMaxWidth: OleVariant;
                                var AMaxHeight: OleVariant; AFileFormat: Integer;
                                AViewCont: Integer; AViewConv: Integer; const AFilePath: WideString): HResult; stdcall;
    function WGetSlideStudyFile(ASlideID: Integer; var AMaxWidth: OleVariant;
                                var AMaxHeight: OleVariant; AFileFormat: Integer;
                                const AFilePath: WideString; out AItemsRefs: OleVariant): HResult; stdcall;
    function WGetSlideVideoFile(ASlideID: Integer; const AFilePath: WideString): HResult; stdcall;
    function StartSession(AStartCode: Integer): HResult; stdcall;
    function WSetCurrentUser(AUserID: Integer): HResult; stdcall;
    function GetSlideImageFile(ASlideID: Integer; var AMaxWidth: OleVariant;
                               var AMaxHeight: OleVariant; AFileFormat: Integer;
                               AViewCont: Integer; const AFileName: WideString): HResult; stdcall;
  end;

// *********************************************************************//
// The Class CoD4WCMServer provides a Create and CreateRemote method to
// create instances of the default interface ID4WCMServer exposed by
// the CoClass D4WCMServer. The functions are intended to be used by
// clients wishing to automate the CoClass objects exposed by the
// server of this typelibrary.
// *********************************************************************//
  CoD4WCMServer = class
    class function Create: ID4WCMServer;
    class function CreateRemote(const MachineName: string): ID4WCMServer;
  end;

implementation

uses System.Win.ComObj;

class function CoD4WCMServer.Create: ID4WCMServer;
begin
  Result := CreateComObject(CLASS_D4WCMServer) as ID4WCMServer;
end;

class function CoD4WCMServer.CreateRemote(const MachineName: string): ID4WCMServer;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_D4WCMServer) as ID4WCMServer;
end;

end.

