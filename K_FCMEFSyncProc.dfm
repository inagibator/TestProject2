inherited K_FormCMEFSyncProc: TK_FormCMEFSyncProc
  Left = 683
  Top = 489
  Width = 396
  Height = 161
  Caption = 'CMSuite Enterprise Files Synchronization'
  FormStyle = fsStayOnTop
  OnCanResize = nil
  OnCloseQuery = FormCloseQuery
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 381
    Top = 117
    TabOrder = 1
  end
  object Memo: TMemo
    Left = 0
    Top = 0
    Width = 380
    Height = 122
    Align = alClient
    TabOrder = 0
  end
  object Timer: TTimer
    Enabled = False
    Interval = 60000
    OnTimer = TimerTimer
    Left = 16
    Top = 8
  end
end
