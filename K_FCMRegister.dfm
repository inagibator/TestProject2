inherited K_FormCMRegister: TK_FormCMRegister
  Left = 365
  Top = 341
  Width = 512
  Height = 176
  Caption = 'Registration'
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 494
    Top = 132
    TabOrder = 3
  end
  object MemRegInfo: TMemo
    Left = 8
    Top = 8
    Width = 490
    Height = 91
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelInner = bvNone
    BorderStyle = bsNone
    Color = clBtnFace
    Lines.Strings = (
      
        'The system has detected that Centaur Media Suite is registered f' +
        'or 5 user license(s).'
      
        'The Media Suite Database Server (Computer) Identification Number' +
        ' is:: Z34F6HTT'
      'The Media Suite build is XX.XXX Professional'
      ''
      
        'To purchase additional Media Suite user licenses please call Cen' +
        'taur Software Australia Pty. Ltd. on '
      '+61-2-9231-5000 or email on support@centaursoftware.com.au'
      '_')
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object BtOK: TButton
    Left = 356
    Top = 109
    Width = 134
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = 'Continue'
    ModalResult = 1
    TabOrder = 1
  end
  object BtChangeReg: TButton
    Left = 191
    Top = 109
    Width = 155
    Height = 23
    Hint = 'Enter registration code recieved from support service'
    Anchors = [akRight, akBottom]
    Caption = 'Change Registration ...'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 2
    OnClick = BtChangeRegClick
  end
  object OpenDialog: TOpenDialog
    Filter = 'Key files (key*.cms)|key*.cms|All files (*.*)|*.*'
    Left = 160
    Top = 384
  end
end
