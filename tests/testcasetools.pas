Unit testcaseTools;

{$mode objfpc}{$H+}

Interface

Uses
  Classes, SysUtils, uTools, fpcunit, testutils, testregistry;

Type

  { TTestCaseTools }

  TTestCaseTools = Class(TTestCase)
  protected
    Procedure SetUp; override;
    Procedure TearDown; override;
  Published
    Procedure TestHookUp;
    Procedure TestCammelCase;
    Procedure TestGlobCheck;
    Procedure TestGlobCheckAll;
  End;

Implementation

Procedure TTestCaseTools.TestHookUp;
Begin
  AssertEquals('ahoj nazdarek', NormalizeTerm('Ahój, Nazdárek'));
  AssertEquals('prilis zlutoucky kun upel dabelske ody', NormalizeTerm('Příliš  žluťoučký kůň - úpěl ďábelské ódy!'));
End;

Procedure TTestCaseTools.TestCammelCase;
Begin
  AssertEquals('freerapiddownloader', CopyAndSplitCammelCaseString('freerapiddownloader'));
  AssertEquals('freeRapidDownloader free Rapid Downloader', CopyAndSplitCammelCaseString('freeRapidDownloader'));
  AssertEquals('freeRapid1Downloader ahoj free Rapid 1 Downloader ahoj', CopyAndSplitCammelCaseString('freeRapid1Downloader ahoj'));
End;

Procedure TTestCaseTools.TestGlobCheck;
Begin
  AssertTrue(GlobCheck('*aa*', 'aaaa'));
  AssertFalse(GlobCheck('*ab*', 'aaaa'));

  AssertTrue(GlobCheck('*aa', 'bbaa'));
  AssertFalse(GlobCheck('*aa', 'bbaab'));
  AssertFalse(GlobCheck('*aa', 'bbba'));

  AssertTrue(GlobCheck('aa*', 'aabb'));
  AssertFalse(GlobCheck('aa*', 'bbba'));

  AssertTrue(GlobCheck('aa', 'aa'));
  AssertTrue(GlobCheck('aa', 'AA'));
  AssertFalse(GlobCheck('aa', 'ba'));
End;

Procedure TTestCaseTools.TestGlobCheckAll;
Begin
  AssertTrue(GlobCheckAll('*aa*:*cc', 'ddaadd'));
  AssertTrue(GlobCheckAll('*xx*:*cc*', 'ddaaccdd'));
  AssertFalse(GlobCheckAll('*xx*:*cc*', 'ddaacdd'));
End;



Procedure TTestCaseTools.SetUp;
Begin

End;

Procedure TTestCaseTools.TearDown;
Begin

End;

Initialization

  RegisterTest(TTestCaseTools);
End.

