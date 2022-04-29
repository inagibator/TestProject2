inherited K_FormCMSFlashlightModeAttrs: TK_FormCMSFlashlightModeAttrs
  Left = 303
  Top = 260
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = '  Flashlight Attributes'
  ClientHeight = 329
  ClientWidth = 297
  OnCloseQuery = FormCloseQuery
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 287
    Top = 319
    TabOrder = 4
  end
  object BtCancel: TButton
    Left = 209
    Top = 298
    Width = 80
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 0
  end
  object BtOK: TButton
    Left = 115
    Top = 298
    Width = 80
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    ModalResult = 1
    TabOrder = 1
  end
  object GBGamma: TGroupBox
    Left = 8
    Top = 87
    Width = 282
    Height = 65
    Anchors = [akLeft, akTop, akRight]
    Caption = '  Gamma  '
    TabOrder = 2
    DesignSize = (
      282
      65)
    object Label3: TLabel
      Left = 15
      Top = 22
      Width = 36
      Height = 13
      Caption = '&Gamma'
      FocusControl = TBGamma
    end
    object TBGamma: TTrackBar
      Left = 68
      Top = 20
      Width = 150
      Height = 33
      Anchors = [akLeft, akTop, akRight]
      LineSize = 7
      Max = 1000
      PageSize = 70
      Frequency = 100
      Position = 500
      TabOrder = 0
      OnChange = TBValChange
    end
    object EdGamVal: TEdit
      Left = 228
      Top = 23
      Width = 38
      Height = 17
      Anchors = [akTop, akRight]
      AutoSize = False
      Color = 10682367
      TabOrder = 1
      Text = '  -99.5'
      OnEnter = EdGamValEnter
      OnKeyDown = EdGamValKeyDown
    end
  end
  object GBZoom: TGroupBox
    Left = 8
    Top = 8
    Width = 282
    Height = 73
    Anchors = [akLeft, akTop, akRight]
    Caption = '  Zoom  '
    TabOrder = 3
    DesignSize = (
      282
      73)
    object Label4: TLabel
      Left = 14
      Top = 23
      Width = 57
      Height = 13
      Caption = '&Zoom factor'
      FocusControl = TBZoom
    end
    object Label1_: TLabel
      Left = 85
      Top = 51
      Width = 11
      Height = 13
      Caption = 'x1'
    end
    object Label2_: TLabel
      Left = 163
      Top = 51
      Width = 11
      Height = 13
      Caption = 'x5'
    end
    object Label6_: TLabel
      Left = 256
      Top = 51
      Width = 17
      Height = 13
      Caption = 'x10'
    end
    object TBZoom: TTrackBar
      Left = 80
      Top = 18
      Width = 194
      Height = 33
      Anchors = [akLeft, akTop, akRight]
      LineSize = 10
      Max = 900
      PageSize = 100
      Frequency = 100
      Position = 400
      TabOrder = 0
      OnChange = TBValChange
    end
  end
  object RGSize_4: TRadioGroup
    Left = 115
    Top = 232
    Width = 175
    Height = 57
    Caption = '  Size  '
    Columns = 4
    ItemIndex = 0
    Items.Strings = (
      '1x'
      '1.5x'
      '2x'
      '3x')
    TabOrder = 5
    OnClick = TBValChange
  end
  object RGShape: TRadioGroup
    Left = 115
    Top = 158
    Width = 175
    Height = 57
    Caption = '  Shape  '
    Columns = 2
    ItemIndex = 0
    Items.Strings = (
      '&Ellipse'
      '&Rectangle')
    TabOrder = 6
    OnClick = TBValChange
  end
  object RGMode: TRadioGroup
    Left = 8
    Top = 158
    Width = 97
    Height = 131
    ItemIndex = 0
    Items.Strings = (
      'No change'
      'Negate'
      'Equalize'
      'Colorize'
      'Emboss')
    TabOrder = 7
    OnClick = TBValChange
  end
end
