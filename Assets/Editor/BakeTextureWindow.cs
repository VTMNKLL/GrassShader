using UnityEngine;
using UnityEditor;
using System.IO;
using System;

// https://www.ronja-tutorials.com/2018/10/13/baking_shaders.html

public class BakeTextureWindow : EditorWindow
{

    Material ImageMaterial;
    //RenderTexture rtex;
    string FilePath = "Assets/MaterialImage.png";
    Vector2Int Resolution;
    Texture2D tex;

    bool hasMaterial;
    bool hasResolution;
    bool hasFilePath;

    [MenuItem("Tools/TextureBaker")]
    static void OpenWindow()
    {
        //create window
        BakeTextureWindow window = EditorWindow.GetWindow<BakeTextureWindow>();
        window.Show();

        window.CheckInput();
    }

    void OnGUI()
    {
        EditorGUILayout.HelpBox("Set the material you want to bake as well as the size " +
                "and location of the texture you want to bake to, then press the \"Bake\" button.", MessageType.None);
        using (var check = new EditorGUI.ChangeCheckScope())
        {
            ImageMaterial = (Material)EditorGUILayout.ObjectField("Material", ImageMaterial, typeof(Material), false);
            //rtex = (RenderTexture)EditorGUILayout.ObjectField("Material", rtex, typeof(RenderTexture), false);
            Resolution = EditorGUILayout.Vector2IntField("Image Resolution", Resolution);
            FilePath = FileField(FilePath);

            if (check.changed)
            {
                CheckInput();
            }
        }

        GUI.enabled = hasMaterial && hasResolution;
        Debug.Log("Previewing Texture");
       

        GUI.enabled = hasMaterial && hasResolution && hasFilePath;
        GUILayout.BeginHorizontal();
        if (GUILayout.Button("Preview"))
        {
            PreviewTexture();
            //tex = (Texture2D)EditorGUILayout.ObjectField("Image", tex, typeof(Texture2D), false);
            //var fillColorArray = tex.GetPixels();

            //for (var i = 0; i < fillColorArray.Length; ++i)
            //{
            //    fillColorArray[i] = Color.black;
            //}

            //tex.SetPixels(fillColorArray);
            //tex.SetPixel(0,0,Color.black);
            //tex.Apply();
            //GUI.DrawTexture(new Rect(0, 0, position.width, position.height), tex, ScaleMode.ScaleToFit, false, 0.0f);
        }
        if (GUILayout.Button("Bake"))
        {
            BakeTexture();
        }
        
        GUILayout.EndHorizontal();
        GUILayout.Label(tex);
        GUI.enabled = true;

        //tell the user what inputs are missing
        if (!hasMaterial)
        {
            EditorGUILayout.HelpBox("You're still missing a material to bake.", MessageType.Warning);
        }
        if (!hasResolution)
        {
            EditorGUILayout.HelpBox("Please set a size bigger than zero.", MessageType.Warning);
        }
        if (!hasFilePath)
        {
            EditorGUILayout.HelpBox("No file to save the image to given.", MessageType.Warning);
        }
    }

    void CheckInput()
    {
        //check which values are entered already
        hasMaterial = ImageMaterial != null;
        hasResolution = Resolution.x > 0 && Resolution.y > 0;
        hasFilePath = false;
        try
        {
            string ext = Path.GetExtension(FilePath);
            hasFilePath = ext.Equals(".png");
        }
        catch (ArgumentException) { }
    }

    string FileField(string path)
    {
        //allow the user to enter output file both as text or via file browser
        EditorGUILayout.LabelField("Image Path");
        using (new GUILayout.HorizontalScope())
        {
            path = EditorGUILayout.TextField(path);
            if (GUILayout.Button("choose"))
            {
                //set default values for directory, then try to override them with values of existing path
                string directory = "Assets";
                string fileName = "MaterialImage.png";
                try
                {
                    directory = Path.GetDirectoryName(path);
                    fileName = Path.GetFileName(path);
                }
                catch (ArgumentException) { }
                string chosenFile = EditorUtility.SaveFilePanelInProject("Choose image file", fileName,
                        "png", "Please enter a file name to save the image to", directory);
                if (!string.IsNullOrEmpty(chosenFile))
                {
                    path = chosenFile;
                }
                //repaint editor because the file changed and we can't set it in the textfield retroactively
                Repaint();
            }
        }
        return path;
    }
    Texture2D toTexture2D(RenderTexture rTex)
    {
        Texture2D tex = new Texture2D(Resolution.x, Resolution.y, TextureFormat.RGBA32, false);
        RenderTexture.active = rTex;
        tex.ReadPixels(new Rect(0, 0, rTex.width, rTex.height), 0, 0);
        tex.Apply();
        return tex;
    }
    void PreviewTexture()
    {
        //render material to rendertexture
        RenderTexture renderTexture = RenderTexture.GetTemporary(Resolution.x, Resolution.y);
        Graphics.Blit(null, renderTexture, ImageMaterial);

        //transfer image from rendertexture to texture
        //tex = new Texture2D(Resolution.x, Resolution.y);
        //RenderTexture.active = renderTexture;
        //tex.ReadPixels(new Rect(Vector2.zero, Resolution), 0, 0);
        //tex.Apply();
        tex = toTexture2D(renderTexture);

        //clean up variables
        RenderTexture.active = null;
        RenderTexture.ReleaseTemporary(renderTexture);
    }

    void BakeTexture()
    {
        //render material to rendertexture
        RenderTexture renderTexture = RenderTexture.GetTemporary(Resolution.x, Resolution.y);
        Graphics.Blit(null, renderTexture, ImageMaterial);

        //transfer image from rendertexture to texture
        Texture2D texture = new Texture2D(Resolution.x, Resolution.y);
        RenderTexture.active = renderTexture;
        texture.ReadPixels(new Rect(Vector2.zero, Resolution), 0, 0);

        //save texture to file
        byte[] png = texture.EncodeToPNG();
        File.WriteAllBytes(FilePath, png);
        AssetDatabase.Refresh();

        //clean up variables
        RenderTexture.active = null;
        RenderTexture.ReleaseTemporary(renderTexture);
        DestroyImmediate(texture);
    }
}