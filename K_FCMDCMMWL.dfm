object K_FormCMDCMMWL: TK_FormCMDCMMWL
  Left = 159
  Top = 2
  Width = 723
  Height = 504
  Anchors = [akLeft, akBottom]
  Caption = 'DICOM MWL'
  Color = clBtnFace
  Constraints.MinHeight = 504
  Constraints.MinWidth = 688
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  DesignSize = (
    707
    465)
  PixelsPerInch = 96
  TextHeight = 13
  object StringGrid1: TStringGrid
    Left = 18
    Top = 277
    Width = 657
    Height = 132
    Anchors = [akLeft, akRight, akBottom]
    ColCount = 10
    FixedCols = 0
    RowCount = 2
    Options = [goFixedVertLine, goVertLine, goHorzLine, goRangeSelect, goColSizing]
    TabOrder = 0
    OnClick = StringGrid1Click
  end
  object bnOK: TButton
    Left = 600
    Top = 415
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 1
  end
  object GroupBox1: TGroupBox
    Left = 18
    Top = 8
    Width = 657
    Height = 57
    Anchors = [akLeft, akTop, akRight]
    Caption = '  DICOM Server         '
    TabOrder = 2
    DesignSize = (
      657
      57)
    object Label5: TLabel
      Left = 8
      Top = 24
      Width = 55
      Height = 13
      Caption = 'PACS AET: '
    end
    object Label6: TLabel
      Left = 155
      Top = 24
      Width = 91
      Height = 13
      Caption = 'Server IP-address:'
    end
    object Label7: TLabel
      Left = 326
      Top = 24
      Width = 98
      Height = 13
      Caption = 'Server Port number:'
    end
    object Label8: TLabel
      Left = 480
      Top = 24
      Width = 74
      Height = 13
      Caption = 'Calling AE Title:'
    end
    object StateShape: TShape
      Left = 88
      Top = 0
      Width = 16
      Height = 16
      Brush.Color = clGray
      Pen.Color = clGreen
      Shape = stCircle
    end
    object LbServerPort: TLabel
      Left = 425
      Top = 24
      Width = 36
      Height = 13
      Caption = '_SP___'
    end
    object LbServerName: TLabel
      Left = 76
      Top = 24
      Width = 61
      Height = 13
      Caption = '_SN_______'
    end
    object LbServerIP: TLabel
      Left = 247
      Top = 24
      Width = 64
      Height = 13
      Caption = '_SI-__-__-__'
    end
    object LbAppEntity: TLabel
      Left = 556
      Top = 24
      Width = 85
      Height = 13
      Anchors = [akLeft, akTop, akRight]
      Caption = '_AE___________'
    end
  end
  object GroupBox2: TGroupBox
    Left = 18
    Top = 71
    Width = 657
    Height = 194
    Anchors = [akLeft, akTop, akRight]
    Caption = '  Settings  '
    TabOrder = 3
    DesignSize = (
      657
      194)
    object Label1: TLabel
      Left = 24
      Top = 27
      Width = 44
      Height = 13
      Caption = 'Modality:'
    end
    object Label2: TLabel
      Left = 24
      Top = 89
      Width = 177
      Height = 13
      Caption = 'Scheduled Procedure Date and Time:'
    end
    object Label3: TLabel
      Left = 309
      Top = 27
      Width = 103
      Height = 13
      Anchors = [akTop, akRight]
      Caption = 'Performing Physician:'
    end
    object Label4: TLabel
      Left = 309
      Top = 73
      Width = 52
      Height = 13
      Anchors = [akTop, akRight]
      Caption = 'Patient ID:'
    end
    object Label9: TLabel
      Left = 309
      Top = 119
      Width = 68
      Height = 13
      Anchors = [akTop, akRight]
      Caption = 'Patient Name:'
    end
    object bnClear: TButton
      Left = 571
      Top = 126
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Clear'
      TabOrder = 0
      OnClick = bnClearClick
    end
    object bnSearch: TButton
      Left = 571
      Top = 157
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Search'
      TabOrder = 1
      OnClick = bnSearchClick
    end
    object CheckBox1: TCheckBox
      Left = 24
      Top = 135
      Width = 97
      Height = 17
      Caption = 'Any Date'
      Checked = True
      State = cbChecked
      TabOrder = 2
      OnClick = CheckBox1Click
    end
    object ComboBox1: TComboBox
      Left = 24
      Top = 46
      Width = 65
      Height = 21
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 3
      Text = 'Any'
      Items.Strings = (
        'Any'
        'IO'
        'CR')
    end
    object DateTimePicker1: TDateTimePicker
      Left = 24
      Top = 108
      Width = 97
      Height = 21
      Date = 43831.000000000000000000
      Time = 43831.000000000000000000
      Enabled = False
      TabOrder = 4
    end
    object DateTimePicker2: TDateTimePicker
      Left = 127
      Top = 108
      Width = 66
      Height = 21
      Date = 44005.000000000000000000
      Time = 44005.000000000000000000
      Enabled = False
      Kind = dtkTime
      TabOrder = 5
    end
    object edPatID: TEdit
      Left = 309
      Top = 92
      Width = 57
      Height = 21
      Anchors = [akTop, akRight]
      TabOrder = 6
      Text = 'edPatID'
    end
    object edPatName: TEdit
      Left = 309
      Top = 138
      Width = 121
      Height = 21
      Anchors = [akTop, akRight]
      TabOrder = 7
      Text = 'edPatName'
    end
    object edPhys: TEdit
      Left = 309
      Top = 46
      Width = 121
      Height = 21
      Anchors = [akTop, akRight]
      TabOrder = 8
      Text = 'edPhys'
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 446
    Width = 707
    Height = 19
    Panels = <
      item
        Text = 'Ready'
        Width = 50
      end>
  end
end
