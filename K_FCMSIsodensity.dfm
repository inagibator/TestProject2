inherited K_FormCMSIsodensity: TK_FormCMSIsodensity
  Left = 183
  Top = 336
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = '  Isodensity Attributes'
  ClientHeight = 176
  ClientWidth = 352
  FormStyle = fsStayOnTop
  OldCreateOrder = True
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object LbRange: TLabel [0]
    Left = 8
    Top = 14
    Width = 32
    Height = 13
    Caption = 'Range'
  end
  object LbColor: TLabel [1]
    Left = 8
    Top = 114
    Width = 52
    Height = 13
    Caption = 'Draw Color'
  end
  object LbTransp: TLabel [2]
    Left = 8
    Top = 63
    Width = 65
    Height = 13
    Caption = 'Transparency'
  end
  object LbR0: TLabel [3]
    Left = 108
    Top = 40
    Width = 6
    Height = 13
    Caption = '0'
  end
  object LbT0: TLabel [4]
    Left = 108
    Top = 87
    Width = 6
    Height = 13
    Caption = '0'
  end
  object LbR100: TLabel [5]
    Left = 312
    Top = 40
    Width = 26
    Height = 13
    Anchors = [akTop, akRight]
    Caption = '100%'
  end
  object LbT100: TLabel [6]
    Left = 312
    Top = 87
    Width = 26
    Height = 13
    Anchors = [akTop, akRight]
    Caption = '100%'
  end
  object LbT50: TLabel [7]
    Left = 205
    Top = 87
    Width = 20
    Height = 13
    Caption = '50%'
  end
  object LbR50: TLabel [8]
    Left = 205
    Top = 40
    Width = 20
    Height = 13
    Caption = '50%'
  end
  inherited BFMinBRPanel: TPanel
    Left = 342
    Top = 166
    TabOrder = 5
  end
  object ColorBox: TColorBox
    Left = 111
    Top = 111
    Width = 218
    Height = 22
    Style = [cbStandardColors, cbPrettyNames]
    ItemHeight = 16
    TabOrder = 0
    OnChange = TBRangeChange
  end
  object TBRange: TTrackBar
    Left = 99
    Top = 14
    Width = 235
    Height = 26
    Anchors = [akLeft, akTop, akRight]
    LineSize = 39
    Max = 10000
    PageSize = 195
    Frequency = 1000
    TabOrder = 1
    ThumbLength = 16
    OnChange = TBRangeChange
  end
  object TBTransp: TTrackBar
    Left = 99
    Top = 61
    Width = 235
    Height = 26
    Anchors = [akLeft, akTop, akRight]
    LineSize = 100
    Max = 10000
    PageSize = 500
    Frequency = 1000
    TabOrder = 2
    ThumbLength = 16
    OnChange = TBRangeChange
  end
  object BtOK: TButton
    Left = 148
    Top = 144
    Width = 84
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    ModalResult = 1
    TabOrder = 3
    OnClick = BtOKClick
  end
  object BtCancel: TButton
    Left = 243
    Top = 144
    Width = 84
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 4
    OnClick = BtCancelClick
  end
end
