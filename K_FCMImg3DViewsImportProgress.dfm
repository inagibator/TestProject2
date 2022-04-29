inherited K_FormCMImg3DViewsImportProgress: TK_FormCMImg3DViewsImportProgress
  Left = 377
  Top = 144
  BorderIcons = []
  BorderStyle = bsSingle
  Caption = '3D Image Views importing ...'
  ClientHeight = 41
  ClientWidth = 271
  FormStyle = fsStayOnTop
  OldCreateOrder = True
  Position = poDesktopCenter
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 259
    Top = 29
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 22
    Width = 271
    Height = 19
    Panels = <
      item
        Width = 50
      end
      item
        Width = 50
      end>
  end
  object PBProgress: TProgressBar
    Left = 2
    Top = 1
    Width = 268
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Smooth = True
    TabOrder = 2
  end
end
