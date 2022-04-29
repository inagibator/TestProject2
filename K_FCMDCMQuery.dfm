inherited K_FormCMDCMQuery: TK_FormCMDCMQuery
  Left = 313
  Top = 152
  Width = 542
  Height = 317
  Caption = 'DICOM Query/Retrieve'
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 514
    Top = 266
  end
  object ListView2: TListView
    Left = 5
    Top = 200
    Width = 513
    Height = 42
    Anchors = [akLeft, akTop, akRight, akBottom]
    Checkboxes = True
    Columns = <
      item
        Caption = 'Patient ID'
        Width = 80
      end
      item
        Caption = 'Patient Surname'
        Width = 150
      end
      item
        Caption = 'Patient First name'
        Width = 100
      end
      item
        Caption = 'Patient DOB'
        Width = 85
      end
      item
        Alignment = taCenter
        Caption = 'Patient Gender'
        Width = 85
      end>
    ColumnClick = False
    GridLines = True
    ReadOnly = True
    TabOrder = 1
    ViewStyle = vsReport
    OnClick = ListView2Click
  end
  object BtRetrieve: TButton
    Left = 381
    Top = 249
    Width = 65
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&Retrieve'
    Enabled = False
    TabOrder = 2
    OnClick = BtRetrieveClick
  end
  object BtCancel: TButton
    Left = 454
    Top = 249
    Width = 65
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&Close'
    ModalResult = 2
    TabOrder = 3
  end
  object GroupBox1: TGroupBox
    Left = 300
    Top = 8
    Width = 221
    Height = 121
    Anchors = [akLeft, akTop, akRight]
    Caption = '  DICOM Server         '
    TabOrder = 4
    object Label1: TLabel
      Left = 8
      Top = 18
      Width = 68
      Height = 13
      Caption = 'Server Name: '
    end
    object Label2: TLabel
      Left = 8
      Top = 44
      Width = 87
      Height = 13
      Caption = 'Server IP-address:'
    end
    object Label3: TLabel
      Left = 8
      Top = 70
      Width = 94
      Height = 13
      Caption = 'Server Port number:'
    end
    object Label4: TLabel
      Left = 8
      Top = 96
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
      Left = 120
      Top = 70
      Width = 20
      Height = 13
      Caption = '_SP'
    end
    object LbServerName: TLabel
      Left = 120
      Top = 18
      Width = 21
      Height = 13
      Caption = '_SN'
    end
    object LbServerIP: TLabel
      Left = 120
      Top = 43
      Width = 16
      Height = 13
      Caption = '_SI'
    end
    object LbAppEntity: TLabel
      Left = 120
      Top = 96
      Width = 20
      Height = 13
      Caption = '_AE'
    end
  end
  object BtQuery: TButton
    Left = 455
    Top = 137
    Width = 65
    Height = 23
    Anchors = [akTop, akRight]
    Caption = '&Query'
    Enabled = False
    TabOrder = 5
    OnClick = BtQueryClick
  end
  object GroupBox2: TGroupBox
    Left = 5
    Top = 8
    Width = 288
    Height = 153
    Caption = '  Query parameters  '
    TabOrder = 6
    DesignSize = (
      288
      153)
    object LbFrom: TLabel
      Left = 8
      Top = 125
      Width = 23
      Height = 13
      Caption = 'From'
    end
    object LbTo: TLabel
      Left = 158
      Top = 125
      Width = 13
      Height = 13
      Caption = 'To'
    end
    object LEdPatSurname: TLabeledEdit
      Left = 100
      Top = 15
      Width = 179
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      Color = 10682367
      EditLabel.Width = 90
      EditLabel.Height = 13
      EditLabel.Caption = 'Patient Surname:   '
      LabelPosition = lpLeft
      TabOrder = 0
    end
    object LEdPatFirstname: TLabeledEdit
      Left = 100
      Top = 41
      Width = 179
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      Color = 10682367
      EditLabel.Width = 90
      EditLabel.Height = 13
      EditLabel.Caption = 'Patient First name: '
      LabelPosition = lpLeft
      TabOrder = 1
    end
    object LEdPatID: TLabeledEdit
      Left = 100
      Top = 69
      Width = 179
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      Color = 10682367
      EditLabel.Width = 89
      EditLabel.Height = 13
      EditLabel.Caption = 'Patient ID:             '
      LabelPosition = lpLeft
      TabOrder = 2
    end
    object LEdStudyID: TLabeledEdit
      Left = 56
      Top = 95
      Width = 112
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      Color = 10682367
      EditLabel.Width = 47
      EditLabel.Height = 13
      EditLabel.Caption = 'Study ID: '
      LabelPosition = lpLeft
      TabOrder = 3
    end
    object DTPFrom: TDateTimePicker
      Left = 40
      Top = 121
      Width = 99
      Height = 21
      Date = 39542.430481226850000000
      Format = 'dd/MM/yyyy'
      Time = 39542.430481226850000000
      ShowCheckbox = True
      Color = 10682367
      TabOrder = 4
      OnChange = DTPFromChange
    end
    object DTPTo: TDateTimePicker
      Left = 180
      Top = 121
      Width = 99
      Height = 21
      Date = 39542.430481226850000000
      Format = 'dd/MM/yyyy'
      Time = 39542.430481226850000000
      ShowCheckbox = True
      Color = 10682367
      TabOrder = 5
      OnChange = DTPFromChange
    end
    object LEdModality: TLabeledEdit
      Left = 233
      Top = 95
      Width = 46
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      Color = 10682367
      EditLabel.Width = 45
      EditLabel.Height = 13
      EditLabel.Caption = 'Modality: '
      LabelPosition = lpLeft
      TabOrder = 6
    end
  end
  object BtReset: TButton
    Left = 300
    Top = 137
    Width = 65
    Height = 23
    Caption = 'Re&set'
    TabOrder = 7
    OnClick = BtResetClick
  end
  object CmBHistory: TComboBox
    Left = 6
    Top = 170
    Width = 515
    Height = 21
    ItemHeight = 13
    TabOrder = 8
  end
  object ScrollBar1: TScrollBar
    Left = 24
    Top = 248
    Width = 121
    Height = 17
    PageSize = 0
    TabOrder = 9
  end
end
