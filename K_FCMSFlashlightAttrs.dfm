inherited K_FormCMSFlashlightAttrs: TK_FormCMSFlashlightAttrs
  Left = 350
  Top = 260
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = '  Magnify Region Attributes'
  ClientHeight = 396
  ClientWidth = 297
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 287
    Top = 386
    TabOrder = 5
  end
  object BtCancel: TButton
    Left = 197
    Top = 365
    Width = 80
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 0
  end
  object BtOK: TButton
    Left = 108
    Top = 365
    Width = 80
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    ModalResult = 1
    TabOrder = 1
  end
  object GBEqualize: TGroupBox
    Left = 8
    Top = 112
    Width = 282
    Height = 129
    Anchors = [akLeft, akTop, akRight]
    Caption = '  Equalize  '
    TabOrder = 2
    DesignSize = (
      282
      129)
    object Label3: TLabel
      Left = 14
      Top = 22
      Width = 49
      Height = 13
      Caption = '&Brightness'
      FocusControl = TBBrightness
    end
    object Label5: TLabel
      Left = 14
      Top = 59
      Width = 39
      Height = 13
      Caption = 'Co&ntrast'
      FocusControl = TBContrast
    end
    object TBBrightness: TTrackBar
      Left = 80
      Top = 17
      Width = 194
      Height = 33
      Anchors = [akLeft, akTop, akRight]
      Ctl3D = True
      LineSize = 7
      Max = 1000
      ParentCtl3D = False
      PageSize = 70
      Frequency = 100
      Position = 500
      TabOrder = 0
      OnChange = TBValChange
    end
    object TBContrast: TTrackBar
      Left = 80
      Top = 53
      Width = 194
      Height = 33
      Anchors = [akLeft, akTop, akRight]
      LineSize = 7
      Max = 1000
      PageSize = 70
      Frequency = 100
      Position = 500
      TabOrder = 1
      OnChange = TBValChange
    end
    object ChBAutoEqualize: TCheckBox
      Left = 14
      Top = 93
      Width = 173
      Height = 17
      Anchors = [akTop, akRight]
      Caption = 'Enable Equ&alize'
      TabOrder = 2
      OnClick = TBValChange
    end
    object bnReset: TButton
      Left = 193
      Top = 90
      Width = 75
      Height = 23
      Caption = '&Default'
      TabOrder = 3
      OnClick = bnResetClick
    end
  end
  object GBZoom: TGroupBox
    Left = 8
    Top = 8
    Width = 282
    Height = 97
    Anchors = [akLeft, akTop, akRight]
    Caption = '  Zoom  '
    TabOrder = 3
    DesignSize = (
      282
      97)
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
    object ChBZoom: TCheckBox
      Left = 14
      Top = 70
      Width = 254
      Height = 17
      Caption = 'Enable Zoo&m'
      TabOrder = 1
      OnClick = TBValChange
    end
  end
  object GBBorder: TGroupBox
    Left = 8
    Top = 248
    Width = 282
    Height = 105
    Anchors = [akLeft, akTop, akRight]
    Caption = '  Border/Shape  '
    TabOrder = 4
    object LbColor: TLabel
      Left = 17
      Top = 20
      Width = 24
      Height = 13
      Caption = 'Co&lor'
      FocusControl = ColorBox
    end
    object LbUnit: TLabel
      Left = 138
      Top = 20
      Width = 43
      Height = 13
      Caption = '     &Width'
      FocusControl = CmBLineWidth
    end
    object ColorBox: TColorBox
      Left = 44
      Top = 17
      Width = 88
      Height = 22
      Style = [cbStandardColors, cbPrettyNames]
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ItemHeight = 16
      ParentFont = False
      TabOrder = 0
      OnClick = TBValChange
    end
    object CmBLineWidth: TComboBox
      Left = 185
      Top = 16
      Width = 83
      Height = 22
      Style = csOwnerDrawVariable
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ItemHeight = 16
      ItemIndex = 0
      ParentFont = False
      TabOrder = 1
      Text = ' very thin'
      OnClick = TBValChange
      Items.Strings = (
        ' very thin'
        ' thin '
        ' middle'
        ' thick'
        ' very thick')
    end
    object ChBBorder: TCheckBox
      Left = 13
      Top = 65
      Width = 97
      Height = 17
      Caption = '&Show border'
      TabOrder = 2
      OnClick = TBValChange
    end
    object RGShape: TRadioGroup
      Left = 104
      Top = 46
      Width = 167
      Height = 46
      Caption = '  Shape  '
      Columns = 2
      Items.Strings = (
        '&Ellipse'
        '&Rectangle')
      TabOrder = 3
      OnClick = TBValChange
    end
  end
end
