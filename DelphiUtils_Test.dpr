// JCL_DEBUG_EXPERT_GENERATEJDBG OFF
// JCL_DEBUG_EXPERT_INSERTJDBG OFF
program DelphiUtils_Test;

{$IFDEF CONSOLE_TESTRUNNER}
{$APPTYPE CONSOLE}
{$ENDIF}

uses
	{$If Defined(FASTMM)}
	FastMM4,
	{$EndIf}
	DUnitTestRunner;

{$R *.RES}

begin
	ReportMemoryLeaksOnShutdown := True;
	DUnitTestRunner.RunRegisteredTests;
end.

