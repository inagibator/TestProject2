library D4WScanLib;

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
  K_D4WScanLib in 'K_D4WScanLib.pas',
  K_CM2 in 'K_CM2.pas',
  K_Types in 'K_Types.pas',
  K_CLib0 in 'K_CLib0.pas',
  N_Types in 'N_Types.pas',
  N_Lib0 in 'N_Lib0.pas',
  K_Parse in 'K_parse.pas';

///////////////////////////////////////
// !!! Replace DPR Program Begin
//
//$DPR_BODY_BEGIN

{$R *.res}

exports
  D4WScanAddMessageW,
  D4WScanAddMessage,
  D4WScanCommonInitW,
  D4WScanCommonInit,
  D4WScanSetCurPatientW,
  D4WScanSetCurPatient,
  D4WScanTaskStartW,
  D4WScanTaskStart,
  D4WScanTaskStop,
  D4WScanTaskCheckState,
  D4WScanCommonFree;

begin
end.

//$DPR_BODY_END
//
// !!! Replace DPR Program End
///////////////////////////////////////
