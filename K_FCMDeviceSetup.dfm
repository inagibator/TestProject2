inherited K_FormDeviceSetup: TK_FormDeviceSetup
  Left = 385
  Top = 398
  Width = 332
  Height = 262
  BorderIcons = [biSystemMenu]
  Caption = 'Device Setup'
  KeyPreview = True
  OldCreateOrder = True
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 314
    Top = 218
    TabOrder = 3
  end
  object PageControl: TPageControl
    Left = 8
    Top = 0
    Width = 305
    Height = 190
    ActivePage = TSVideo
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    OnChange = PageControlChange
    object TSTWAIN: TTabSheet
      Caption = 'X-Ray / TWAIN'
      ImageIndex = 1
      DesignSize = (
        297
        162)
      object LbTwain: TLabel
        Left = 11
        Top = 3
        Width = 121
        Height = 13
        Caption = 'X-Ray / TWAIN  Devices'
      end
      object LVTWAIN: TListView
        Left = 9
        Top = 20
        Width = 207
        Height = 136
        Anchors = [akLeft, akTop, akRight, akBottom]
        Color = 10682367
        Columns = <
          item
            AutoSize = True
            Caption = 'A'
          end>
        ReadOnly = True
        RowSelect = True
        ShowColumnHeaders = False
        TabOrder = 0
        ViewStyle = vsReport
        OnSelectItem = LVTWAINSelectItem
      end
      object BtAddProfileTWAIN: TButton
        Left = 227
        Top = 75
        Width = 66
        Height = 21
        Action = AddProfile
        Anchors = [akRight, akBottom]
        TabOrder = 1
      end
      object BtDelProfileTWAIN: TButton
        Left = 227
        Top = 105
        Width = 65
        Height = 21
        Action = DelProfile
        Anchors = [akRight, akBottom]
        TabOrder = 2
      end
      object BtEditProfileTWAIN: TButton
        Left = 227
        Top = 135
        Width = 65
        Height = 21
        Action = EditProfile
        Anchors = [akRight, akBottom]
        TabOrder = 3
      end
      object BtCopyProfileTWAIN: TButton
        Left = 227
        Top = 45
        Width = 66
        Height = 21
        Action = DelProfile
        Anchors = [akRight, akBottom]
        TabOrder = 4
      end
    end
    object TSOther: TTabSheet
      Caption = 'X-Ray / Other '
      ImageIndex = 2
      DesignSize = (
        297
        162)
      object LbOther: TLabel
        Left = 11
        Top = 3
        Width = 108
        Height = 13
        Caption = 'X-Ray / Other Devices'
      end
      object LVOther: TListView
        Left = 9
        Top = 20
        Width = 207
        Height = 136
        Anchors = [akLeft, akTop, akRight, akBottom]
        Color = 10682367
        Columns = <
          item
            AutoSize = True
            Caption = 'A'
          end>
        ReadOnly = True
        RowSelect = True
        ShowColumnHeaders = False
        TabOrder = 0
        ViewStyle = vsReport
      end
      object BtAddProfileOther: TButton
        Left = 227
        Top = 75
        Width = 66
        Height = 21
        Action = AddProfile
        Anchors = [akRight, akBottom]
        TabOrder = 1
      end
      object BtDelProfileOther: TButton
        Left = 227
        Top = 105
        Width = 65
        Height = 21
        Action = DelProfile
        Anchors = [akRight, akBottom]
        TabOrder = 2
      end
      object BtEditProfileOther: TButton
        Left = 227
        Top = 135
        Width = 65
        Height = 21
        Action = EditProfile
        Anchors = [akRight, akBottom]
        TabOrder = 3
      end
      object BtCopyProfileOther: TButton
        Left = 227
        Top = 45
        Width = 66
        Height = 21
        Action = CopyProfile
        Anchors = [akRight, akBottom]
        TabOrder = 4
      end
    end
    object TSOther3D: TTabSheet
      Caption = 'Other / 3D'
      ImageIndex = 3
      DesignSize = (
        297
        162)
      object LbOther3D: TLabel
        Left = 11
        Top = 3
        Width = 93
        Height = 13
        Caption = 'Other / 3D Devices'
      end
      object LVOther3D: TListView
        Left = 9
        Top = 20
        Width = 207
        Height = 136
        Anchors = [akLeft, akTop, akRight, akBottom]
        Color = 10682367
        Columns = <
          item
            AutoSize = True
            Caption = 'A'
          end>
        ReadOnly = True
        RowSelect = True
        ShowColumnHeaders = False
        TabOrder = 0
        ViewStyle = vsReport
      end
      object BtCopyProfileOther3D: TButton
        Left = 227
        Top = 45
        Width = 66
        Height = 21
        Action = CopyProfile
        Anchors = [akRight, akBottom]
        TabOrder = 1
      end
      object BtAddProfileOther3D: TButton
        Left = 227
        Top = 75
        Width = 66
        Height = 21
        Action = AddProfile
        Anchors = [akRight, akBottom]
        TabOrder = 2
      end
      object BtDelProfileOther3D: TButton
        Left = 227
        Top = 105
        Width = 65
        Height = 21
        Action = DelProfile
        Anchors = [akRight, akBottom]
        TabOrder = 3
      end
      object BtEditProfileOther3D: TButton
        Left = 227
        Top = 135
        Width = 65
        Height = 21
        Action = EditProfile
        Anchors = [akRight, akBottom]
        TabOrder = 4
      end
    end
    object TSVideo: TTabSheet
      Caption = 'Video'
      DesignSize = (
        297
        162)
      object LbVideo: TLabel
        Left = 11
        Top = 3
        Width = 69
        Height = 13
        Caption = 'Video Devices'
      end
      object LVVideo: TListView
        Left = 9
        Top = 20
        Width = 207
        Height = 136
        Anchors = [akLeft, akTop, akRight, akBottom]
        Color = 10682367
        Columns = <
          item
            AutoSize = True
            Caption = 'A'
          end>
        ReadOnly = True
        RowSelect = True
        ShowColumnHeaders = False
        TabOrder = 0
        ViewStyle = vsReport
      end
      object BtDelProfileVideo: TButton
        Left = 227
        Top = 105
        Width = 65
        Height = 21
        Action = DelProfile
        Anchors = [akRight, akBottom]
        TabOrder = 1
      end
      object BtAddProfileVideo: TButton
        Left = 227
        Top = 75
        Width = 66
        Height = 21
        Action = AddProfile
        Anchors = [akRight, akBottom]
        TabOrder = 2
      end
      object BtEditProfileVideo: TButton
        Left = 227
        Top = 135
        Width = 65
        Height = 21
        Action = EditProfile
        Anchors = [akRight, akBottom]
        TabOrder = 3
      end
      object BtCopyProfileVideo: TButton
        Left = 227
        Top = 45
        Width = 66
        Height = 21
        Action = CopyProfile
        Anchors = [akRight, akBottom]
        TabOrder = 4
      end
    end
  end
  object BtCancel: TButton
    Left = 250
    Top = 199
    Width = 60
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object BtOK: TButton
    Left = 178
    Top = 199
    Width = 60
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    ModalResult = 1
    TabOrder = 2
  end
  object BtRearrange: TButton
    Left = 8
    Top = 199
    Width = 75
    Height = 21
    Action = Rearrange
    Anchors = [akLeft, akBottom]
    TabOrder = 4
  end
  object TimerContEdit: TTimer
    Enabled = False
    Interval = 10
    Left = 141
    Top = 19
  end
  object ActionList1: TActionList
    Left = 174
    Top = 19
    object AddProfile: TAction
      Caption = '&Add'
      Hint = 'Add new Capture Device Profile'
      OnExecute = AddProfileExecute
    end
    object DelProfile: TAction
      Caption = '&Delete'
      Hint = 'Delete existing Capture Device Profile'
      OnExecute = DelProfileExecute
    end
    object EditProfile: TAction
      Caption = '&Properties'
      Hint = 'Change Capture Device Profile Properties'
      OnExecute = EditProfileExecute
    end
    object CopyProfile: TAction
      Caption = 'Copy'
      OnExecute = CopyProfileExecute
    end
    object Rearrange: TAction
      Caption = 'Rearrange'
      OnExecute = RearrangeExecute
    end
  end
end
