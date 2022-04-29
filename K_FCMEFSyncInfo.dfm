inherited K_FormCMEFSyncInfo: TK_FormCMEFSyncInfo
  Left = 826
  Top = 525
  BorderStyle = bsDialog
  Caption = 'Files Synchronization'
  ClientHeight = 252
  ClientWidth = 289
  OldCreateOrder = True
  OnCloseQuery = FormCloseQuery
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 279
    Top = 242
    TabOrder = 3
  end
  object PageControl: TPageControl
    Left = 0
    Top = 0
    Width = 289
    Height = 217
    ActivePage = TSHistory
    Align = alTop
    TabOrder = 0
    object TSSetup: TTabSheet
      Caption = 'Setup'
      object ChBHOfficeSync: TCheckBox
        Left = 8
        Top = 8
        Width = 361
        Height = 17
        Caption = 'Compulsory synchronization to the Central Location'
        TabOrder = 0
      end
      object GBSchedule: TGroupBox
        Left = 8
        Top = 32
        Width = 265
        Height = 81
        Caption = '  Synchronization schedule  '
        TabOrder = 1
        object LbStart: TLabel
          Left = 13
          Top = 35
          Width = 47
          Height = 13
          Caption = 'Start time:'
        end
        object LbEndTime: TLabel
          Left = 141
          Top = 35
          Width = 44
          Height = 13
          Caption = 'End time:'
        end
        object DTPStartTime: TDateTimePicker
          Left = 65
          Top = 32
          Width = 61
          Height = 21
          Date = 39542.958333333340000000
          Format = ' HH:mm'
          Time = 39542.958333333340000000
          DateFormat = dfLong
          Kind = dtkTime
          TabOrder = 0
        end
        object DTPEndTime: TDateTimePicker
          Left = 193
          Top = 32
          Width = 61
          Height = 21
          Date = 39542.208333333340000000
          Format = ' HH:mm'
          Time = 39542.208333333340000000
          DateFormat = dfLong
          Kind = dtkTime
          TabOrder = 1
        end
      end
      object BtSetupApply: TButton
        Left = 106
        Top = 144
        Width = 65
        Height = 23
        Caption = 'Apply'
        TabOrder = 2
        OnClick = BtSetupApplyClick
      end
    end
    object TSHistory: TTabSheet
      Caption = 'History'
      ImageIndex = 1
      object GBDates: TGroupBox
        Left = 8
        Top = 8
        Width = 265
        Height = 73
        Caption = '  Dates  '
        TabOrder = 0
        object LbFrom: TLabel
          Left = 16
          Top = 32
          Width = 23
          Height = 13
          Caption = 'From'
        end
        object LbTo: TLabel
          Left = 144
          Top = 32
          Width = 13
          Height = 13
          Caption = 'To'
        end
        object DTPFrom: TDateTimePicker
          Left = 48
          Top = 28
          Width = 85
          Height = 21
          Date = 39542.430481226850000000
          Format = 'dd/MM/yyyy'
          Time = 39542.430481226850000000
          Color = 10682367
          TabOrder = 0
        end
        object DTPTo: TDateTimePicker
          Left = 168
          Top = 28
          Width = 85
          Height = 21
          Date = 39542.430481226850000000
          Format = 'dd/MM/yyyy'
          Time = 39542.430481226850000000
          Color = 10682367
          TabOrder = 1
        end
      end
      object BtRequest: TButton
        Left = 32
        Top = 119
        Width = 75
        Height = 23
        Caption = 'Requests'
        TabOrder = 1
        OnClick = BtRequestClick
      end
      object BtCopyLog: TButton
        Left = 176
        Top = 119
        Width = 75
        Height = 23
        Caption = 'Copy Log'
        TabOrder = 2
        OnClick = BtCopyLogClick
      end
      object BtFailures: TButton
        Left = 176
        Top = 151
        Width = 75
        Height = 23
        Caption = 'Failures'
        TabOrder = 3
        OnClick = BtFailuresClick
      end
      object ChBLastSyncSession: TCheckBox
        Left = 32
        Top = 87
        Width = 249
        Height = 17
        Caption = 'Display the last data available'
        TabOrder = 4
        OnClick = ChBLastSyncSessionClick
      end
      object BtSuccess: TButton
        Left = 32
        Top = 151
        Width = 75
        Height = 23
        Caption = 'Success'
        TabOrder = 5
        OnClick = BtSuccessClick
      end
    end
  end
  object BtCancel: TButton
    Left = 216
    Top = 223
    Width = 65
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object BtOK: TButton
    Left = 139
    Top = 223
    Width = 65
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    ModalResult = 1
    TabOrder = 2
  end
end
