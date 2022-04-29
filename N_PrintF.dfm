inherited N_PrintForm: TN_PrintForm
  Left = 298
  Top = 228
  Width = 364
  Height = 293
  Caption = 'Printing'
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel [0]
    Left = 25
    Top = 8
    Width = 114
    Height = 13
    Caption = 'Current Printer Settings :'
  end
  object lbResolution: TLabel [1]
    Left = 8
    Top = 47
    Width = 58
    Height = 13
    Caption = 'lbResolution'
  end
  object lbPaperSize: TLabel [2]
    Left = 8
    Top = 30
    Width = 56
    Height = 13
    Caption = 'lbPaperSize'
  end
  object Label2: TLabel [3]
    Left = 189
    Top = 13
    Width = 79
    Height = 13
    Caption = 'Horizontal Align :'
  end
  object Label3: TLabel [4]
    Left = 202
    Top = 40
    Width = 66
    Height = 13
    Caption = 'Verical Allign :'
  end
  object Bevel1: TBevel [5]
    Left = 173
    Top = 7
    Width = 3
    Height = 62
    Shape = bsRightLine
  end
  inherited BFMinBRPanel: TPanel
    TabOrder = 6
  end
  object bnPrinterSetup: TButton
    Left = 191
    Top = 229
    Width = 71
    Height = 25
    Caption = 'Printer Setup'
    TabOrder = 0
    OnClick = bnPrinterSetupClick
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 72
    Width = 153
    Height = 150
    Caption = '  Margins in mm    '
    TabOrder = 1
    object edTopMargin: TLabeledEdit
      Left = 56
      Top = 17
      Width = 41
      Height = 21
      EditLabel.Width = 31
      EditLabel.Height = 13
      EditLabel.Caption = 'Top :  '
      LabelPosition = lpLeft
      TabOrder = 0
      OnKeyDown = edImageSizeKeyDown
    end
    object edBottomMargin: TLabeledEdit
      Left = 56
      Top = 85
      Width = 41
      Height = 21
      EditLabel.Width = 45
      EditLabel.Height = 13
      EditLabel.Caption = 'Bottom :  '
      LabelPosition = lpLeft
      TabOrder = 1
      OnKeyDown = edImageSizeKeyDown
    end
    object edLeftMargin: TLabeledEdit
      Left = 23
      Top = 58
      Width = 41
      Height = 21
      EditLabel.Width = 24
      EditLabel.Height = 13
      EditLabel.Caption = 'Left :'
      TabOrder = 2
      OnKeyDown = edImageSizeKeyDown
    end
    object edRightMargin: TLabeledEdit
      Left = 90
      Top = 58
      Width = 41
      Height = 21
      EditLabel.Width = 31
      EditLabel.Height = 13
      EditLabel.Caption = 'Right :'
      TabOrder = 3
      OnKeyDown = edImageSizeKeyDown
    end
    object bnSetMinMargins: TButton
      Left = 21
      Top = 115
      Width = 111
      Height = 25
      Caption = 'Set Minimal Margins'
      TabOrder = 4
      OnClick = bnSetMinMarginsClick
    end
  end
  object GroupBox2: TGroupBox
    Left = 186
    Top = 72
    Width = 161
    Height = 149
    Caption = '  Image Size in mm  '
    TabOrder = 2
    object edImageWidth: TLabeledEdit
      Left = 28
      Top = 34
      Width = 41
      Height = 21
      EditLabel.Width = 40
      EditLabel.Height = 13
      EditLabel.Caption = 'Width :  '
      TabOrder = 0
      OnKeyDown = edImageSizeKeyDown
    end
    object edImageHeight: TLabeledEdit
      Left = 91
      Top = 34
      Width = 41
      Height = 21
      EditLabel.Width = 43
      EditLabel.Height = 13
      EditLabel.Caption = 'Height :  '
      TabOrder = 1
      OnKeyDown = edImageSizeKeyDown
    end
    object cbMaxPossibleSize: TCheckBox
      Left = 35
      Top = 64
      Width = 97
      Height = 17
      Caption = 'Max Possible'
      TabOrder = 2
      OnClick = cbMaxPossibleSizeClick
    end
    object cbMantainAspect: TCheckBox
      Left = 35
      Top = 87
      Width = 97
      Height = 17
      Caption = 'Mantain Aspect'
      TabOrder = 3
      OnClick = cbMantainAspectClick
    end
    object bnSetOriginalSize: TButton
      Left = 32
      Top = 114
      Width = 100
      Height = 25
      Caption = 'Set Original Size'
      Enabled = False
      TabOrder = 4
      OnClick = bnSetOriginalSizeClick
    end
  end
  object bnPrint: TButton
    Left = 272
    Top = 229
    Width = 71
    Height = 25
    Caption = 'Print'
    Enabled = False
    TabOrder = 3
    OnClick = bnPrintClick
  end
  object mbHorAlign: TComboBox
    Left = 272
    Top = 9
    Width = 67
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 4
  end
  object mbVertAlign: TComboBox
    Left = 272
    Top = 36
    Width = 67
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 5
  end
  object PrinterSetupDialog: TPrinterSetupDialog
    OnClose = PrinterSetupDialogClose
    Left = 80
    Top = 24
  end
  object Timer: TTimer
    Enabled = False
    Interval = 100
    OnTimer = TimerTimer
    Left = 112
    Top = 24
  end
end
