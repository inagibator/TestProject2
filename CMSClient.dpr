library CMSClient;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }

uses
  K_CMSCom_TLB in 'K_CMSCom_TLB.pas',
  K_CMSComLib in 'K_CMSComLib.pas',
  K_SBuf0 in 'K_SBuf0.pas';

///////////////////////////////////////
// !!! Replace DPR Program Begin
//
//$DPR_BODY_BEGIN

{$R *.res}
exports
  CMSShowMessage,
  CMSGetLibVer,
  CMSRegisterServer,
  CMSStartServer,
  CMSCloseServerEx,
  CMSCloseServer,
  CMSSetCodePage,
  CMSSetCurContext,
  CMSSetCurContextEx,
  CMSSetLocationsInfo,
  CMSSetPatientsInfo,
  CMSSetProvidersInfo,
  CMSSetWindowState,
//  CMSSetAppMode,
  CMSGetPatientMediaCounter,
//  CMSGetWindowHandle,
  CMSSetTraceInfo,
  CMSGetServerInfo,
  CMSSetIniInfo,
  CMSExecUICommand,
  CMSCopyMovePatSlides,
  CMSSetUpdateMode,
  CMSPrepThumbnails,
  CMSGetThumbnail,
  CMSPrepPatSlidesAttrs,
  CMSGetPatSlidesAttrs,
  CMSGetSlideImageFile,
  CMSHPSetCurContext,
  CMSHPSetVisibleIcons,
  CMSHPViewMediaObject;
begin
end.

//$DPR_BODY_END
//
// !!! Replace DPR Program End
///////////////////////////////////////
