defmodule MedirepoWeb.BulletinsController do
  use MedirepoWeb, :controller

  alias Medirepo.Bulletin
  alias MedirepoWeb.Auth.Guardian
  alias MedirepoWeb.FallbackController

  action_fallback FallbackController

  def create(conn, params) do
    with {:ok, logged_hospital} <- Guardian.current_hospital(conn) do
      params = Map.put(params, "hospital_id", logged_hospital)

      with {:ok, %Bulletin{} = bulletin} <- Medirepo.create_bulletin(params) do
        conn
        |> put_status(:created)
        |> render("create.json", bulletin: bulletin)
      end
    end
  end

  def show(conn, %{"id" => id}) do
    with {:ok, _logged_hospital} <- Guardian.current_hospital(conn),
         {:ok, %Bulletin{} = bulletin} <- Medirepo.get_bulletin_by_id(id) do
      conn
      |> put_status(:ok)
      |> render("bulletin.json", bulletin: bulletin)
    end
  end

  def delete(conn, %{"id" => id}) do
    with {:ok, _logged_hospital} <- Guardian.current_hospital(conn),
         {:ok, %Bulletin{}} <- Medirepo.delete_bulletin(id) do
      conn
      |> put_status(:no_content)
      |> text("")
    end
  end

  def update(conn, params) do
    with {:ok, _logged_hospital} <- Guardian.current_hospital(conn),
         {:ok, %Bulletin{} = bulletin} <- Medirepo.update_bulletin(params) do
      conn
      |> put_status(:ok)
      |> render("bulletin.json", bulletin: bulletin)
    end
  end

  def show_list(conn, _params) do
    with {:ok, logged_hospital} <- Guardian.current_hospital(conn),
         {:ok, bulletin} <- Medirepo.get_all_bulletins(logged_hospital) do
      conn
      |> put_status(:ok)
      |> render("bulletin.json", bulletin: bulletin)
    end
  end
end
