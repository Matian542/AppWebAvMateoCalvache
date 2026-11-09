<%@ Page Title="Canciones" Language="C#"
    MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="Song.aspx.cs" Inherits="WebAppPoliMusicV3.Song" %>

<asp:Content ID="BodyContent"
    ContentPlaceHolderID="MainContent" runat="server">

    <style>
        .music-page {
            margin: 30px 0;
            padding: 28px;
            border-radius: 20px;
            background: #101827;
            color: #e5edf9;
        }

        .music-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 16px;
            margin-bottom: 26px;
        }

        .music-header h1 {
            margin: 8px 0;
            font-weight: 700;
        }

        .music-kicker {
            color: #5eead4;
            font-weight: 600;
            letter-spacing: 2px;
        }

        .music-subtitle {
            color: #b5c3d8;
        }

        .music-count {
            padding: 16px 22px;
            border: 1px solid #35445d;
            border-radius: 14px;
            background: #1b2940;
        }

        .music-count strong {
            color: #5eead4;
            font-size: 28px;
            margin-right: 8px;
        }

        .music-scroll {
            overflow-x: auto;
        }

        .music-table {
            width: 100%;
            border-collapse: collapse;
        }

        .music-table th {
            background: #1b2940;
            color: #5eead4;
            padding: 16px;
            text-align: left;
        }

        .music-table td {
            padding: 16px;
            border-bottom: 1px solid #35445d;
        }

        .music-table tr:hover td {
            background: #17243a;
        }

        .music-table audio {
            width: 280px;
            max-width: 100%;
        }

        .music-error {
            display: block;
            color: #fda4af;
            margin-bottom: 16px;
        }
    </style>

    <section class="music-page">
        <div class="music-header">
            <div>
                <span class="music-kicker">BIBLIOTECA POLIMUSIC</span>
                <h1>Tu música, en un solo lugar</h1>
                <p class="music-subtitle">
                    Explora las canciones y reproduce tus favoritas.
                </p>
            </div>

            <div class="music-count">
                <strong>
                    <asp:Label ID="lblCount" runat="server" Text="0" />
                </strong>
                canciones
            </div>
        </div>

        <asp:Label ID="lblMessage" runat="server"
            CssClass="music-error" />

        <div class="music-scroll">
            <asp:GridView ID="gvSongs" runat="server"
                AutoGenerateColumns="False"
                CssClass="music-table"
                GridLines="None"
                EmptyDataText="No hay canciones registradas.">
                <Columns>
                    <asp:BoundField DataField="ID_SONG"
                        HeaderText="ID" />

                    <asp:BoundField DataField="SONG_NAME"
                        HeaderText="Canción" HtmlEncode="true" />

                    <asp:BoundField DataField="PLAYS"
                        HeaderText="Reproducciones" />

                    <asp:TemplateField HeaderText="Escuchar">
                        <ItemTemplate>
                            <audio controls="controls" preload="none"
                                src='<%# GetSongUrl(Eval("SONG_PATH")) %>'>
                                Tu navegador no admite audio.
                            </audio>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </div>
    </section>

    <script>
        document.addEventListener("play", function (event) {
            if (event.target.tagName === "AUDIO") {
                document.querySelectorAll(".music-table audio")
                    .forEach(function (player) {
                        if (player !== event.target) {
                            player.pause();
                        }
                    });
            }
        }, true);
    </script>

</asp:Content>