inherited K_FormCMReportShow: TK_FormCMReportShow
  Left = 339
  Top = 340
  Caption = 'Report'
  ClientHeight = 189
  ClientWidth = 411
  OnCloseQuery = FormCloseQuery
  OnShow = FormShow
  ExplicitWidth = 427
  ExplicitHeight = 228
  PixelsPerInch = 96
  TextHeight = 13
  object LbReportDetails: TLabel [0]
    Left = 8
    Top = 8
    Width = 403
    Height = 17
    Alignment = taCenter
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 'Report Details'
  end
  inherited BFMinBRPanel: TPanel
    Left = 409
    Top = 184
    TabOrder = 5
    ExplicitLeft = 409
    ExplicitTop = 184
  end
  object BtExport: TButton
    Left = 264
    Top = 161
    Width = 65
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&Export'
    TabOrder = 0
    OnClick = BtExportClick
  end
  object Button1: TButton
    Left = 344
    Top = 161
    Width = 65
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = 'Cl&ose'
    ModalResult = 2
    TabOrder = 1
  end
  inline FrRAEdit: TK_FrameRAEdit
    Left = 8
    Top = 26
    Width = 403
    Height = 47
    Anchors = [akLeft, akTop, akRight, akBottom]
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 2
    ExplicitLeft = 8
    ExplicitTop = 26
    ExplicitWidth = 403
    ExplicitHeight = 47
    inherited SGrid: TStringGrid
      Width = 403
      Height = 47
      ExplicitWidth = 403
      ExplicitHeight = 47
    end
  end
  object BtWC: TButton
    Left = 112
    Top = 161
    Width = 131
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = 'Selection to &Clipboard'
    TabOrder = 3
    OnClick = BtWCClick
  end
  object GBExport: TGroupBox
    Left = 8
    Top = 82
    Width = 406
    Height = 67
    Anchors = [akLeft, akRight, akBottom]
    Caption = '  Export  '
    TabOrder = 4
    object RGFormats: TRadioGroup
      Left = 24
      Top = 16
      Width = 233
      Height = 41
      Caption = '  Formats  '
      Columns = 4
      Items.Strings = (
        'HTML'
        'CSV'
        'TAB'
        'TEXT')
      TabOrder = 0
    end
    object ChBOpen: TCheckBox
      Left = 276
      Top = 32
      Width = 109
      Height = 17
      Caption = 'Open exported file'
      TabOrder = 1
    end
  end
  object SaveDialog: TSaveDialog
    Options = [ofHideReadOnly, ofNoTestFileCreate, ofEnableSizing]
    Left = 24
    Top = 65532
  end
end
