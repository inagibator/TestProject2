inherited N_CMMain5Form1: TN_CMMain5Form1
  Left = 284
  Top = 367
  BorderIcons = []
  BorderStyle = bsNone
  Caption = 'N_CMMain5Form1'
  ClientHeight = 592
  ClientWidth = 1048
  KeyPreview = True
  OldCreateOrder = True
  ShowHint = True
  OnKeyPress = FormKeyPress
  ExplicitWidth = 1048
  ExplicitHeight = 592
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 977
    Top = 559
    ExplicitLeft = 977
    ExplicitTop = 559
  end
  object EdFramesPanel: TPanel
    Left = 0
    Top = 0
    Width = 1048
    Height = 592
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    OnResize = CMMEdFramesPanelResize
  end
  object StatusBarTimer: TTimer
    Enabled = False
    OnTimer = StatusBarTimerTimer
    Left = 49
    Top = 9
  end
  object DragThumbsTimer: TTimer
    Enabled = False
    Interval = 75
    OnTimer = DragThumbsTimerTimer
    Left = 9
    Top = 9
  end
  object MaintenancePopupMenu: TPopupMenu
    AutoHotkeys = maManual
    AutoPopup = False
    OnPopup = MaintenancePopupMenuPopup
    Left = 8
    Top = 54
    object Mediaobjectsintegritycheck1: TMenuItem
      Action = N_CMResForm.aServMaintenance
    end
    object Databaserecovery1: TMenuItem
      Action = N_CMResForm.aServDBRecoveryByFiles
    end
    object Showobjecthistory1: TMenuItem
      Action = N_CMResForm.aServSlideHistShow
    end
    object aServXRAYStreamLine1: TMenuItem
      Action = N_CMResForm.aServXRAYStreamLine
      AutoCheck = True
    end
    object aServSetPedalDelay1: TMenuItem
      Action = N_CMResForm.aServSetCaptureDelay
    end
    object ImageandVideoFilesHandling1: TMenuItem
      Action = N_CMResForm.aServFilesHandling
    end
    object ImportDataafterConversion1: TMenuItem
      Action = N_CMResForm.aServImportExtDBDlg
    end
    object Deletedobjectshandling1: TMenuItem
      Action = N_CMResForm.aServDelObjHandling
    end
    object DisplayallobjectsinEmFilesfolder1: TMenuItem
      Action = N_CMResForm.aServECacheAllShow
    end
    object ConvertCMIorRECDtoBMP1: TMenuItem
      Action = N_CMResForm.aServConvCMSImgToBMP1
    end
    object ViewEditStatisticsTable1: TMenuItem
      Action = N_CMResForm.aServEditStatTable
    end
    object SetVideoCodec1: TMenuItem
      Action = N_CMResForm.aServSetVideoCodec
    end
    object BinaryDumpMode1: TMenuItem
      Action = N_CMResForm.aServBinDumpMode
      AutoCheck = True
    end
    object aServShowEnvStrings1: TMenuItem
    end
    object RemoteClientSetup1: TMenuItem
      Action = N_CMResForm.aServRemoteClientSetup
    end
    object AloneModeSetup1: TMenuItem
      Action = N_CMResForm.aServSAModeSetup
    end
    object ScheduleFilesTransfer1: TMenuItem
      AutoCheck = True
    end
    object Setlogfilespath1: TMenuItem
      Action = N_CMResForm.aServSetLogFilesPath
    end
    object N20: TMenuItem
      Caption = '-'
    end
    object ScheduleFilesTransfer2: TMenuItem
      Action = N_CMResForm.aServSelSlidesToSyncQuery
    end
    object ransferfilesbetweenLocations1: TMenuItem
      Action = N_CMResForm.aServEModeFilesSync
    end
    object ExportData1: TMenuItem
      Action = N_CMResForm.aServExportPPL
    end
    object ImportData1: TMenuItem
      Action = N_CMResForm.aServImportPPL
    end
  end
  object ActTimer: TTimer
    Enabled = False
    Interval = 1
    OnTimer = ActTimerTimer
    Left = 88
    Top = 9
  end
  object MeasureTextTimer: TTimer
    Enabled = False
    Interval = 500
    OnTimer = MeasureTextTimerTimer
    Left = 126
    Top = 9
  end
  object MainActions: TActionList
    Left = 48
    Top = 54
    object aServDisableActions: TAction
      Category = 'Service'
      Caption = 'Check Actions'
      OnExecute = CMMFDisableActions
    end
    object aOpenMainForm6: TAction
      Category = 'Service'
      Caption = 'Open Main Form 6'
      OnExecute = aOpenMainForm6Execute
    end
    object aOpenMainForm5: TAction
      Category = 'Service'
      Caption = 'Open Main Form 5'
      OnExecute = aOpenMainForm5Execute
    end
  end
end
