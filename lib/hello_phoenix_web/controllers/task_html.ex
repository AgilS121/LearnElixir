defmodule HelloPhoenixWeb.TaskHTML do
  use HelloPhoenixWeb, :html

  embed_templates "task_html/*"

  @doc """
  Renders the task form component.
  """
  def form_component(assigns) do
    ~H"""
    <.form :let={f} for={@changeset} action={@action}>
      <%= if @changeset.action do %>
        <div class="bg-red-50 border border-red-200 rounded-md p-4 mb-6">
          <div class="flex">
            <div class="flex-shrink-0">
              <svg class="h-5 w-5 text-red-400" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd" />
              </svg>
            </div>
            <div class="ml-3">
              <h3 class="text-sm font-medium text-red-800">
                Oops, something went wrong! Please check the errors below.
              </h3>
            </div>
          </div>
        </div>
      <% end %>

      <div class="space-y-6">
        <!-- Title Field -->
        <div>
          <.label for={f[:title].id} class="block text-sm font-medium text-gray-700 mb-1">
            Task Title <span class="text-red-500">*</span>
          </.label>
          <.input
            field={f[:title]}
            type="text"
            class="block w-full px-3 py-2 border border-gray-300 rounded-lg shadow-sm placeholder-gray-400 focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm"
            placeholder="What do you need to do?"
            required
          />
        </div>

        <!-- Description Field -->
        <div>
          <.label for={f[:description].id} class="block text-sm font-medium text-gray-700 mb-1">
            Description (optional)
          </.label>
          <.input
            field={f[:description]}
            type="textarea"
            class="block w-full px-3 py-2 border border-gray-300 rounded-lg shadow-sm placeholder-gray-400 focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm"
            placeholder="Add more details about this task..."
            rows="4"
          />
        </div>

        <!-- Completed Checkbox -->
        <div class="flex items-center">
          <.input field={f[:completed]} type="checkbox" class="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded" />
          <.label for={f[:completed].id} class="ml-3 text-sm font-medium text-gray-700">
            Mark as completed
          </.label>
        </div>

        <!-- Action Buttons -->
        <div class="flex items-center justify-between pt-6 border-t border-gray-200">
          <.link
            navigate={~p"/tasks"}
            class="inline-flex items-center px-4 py-2 border border-gray-300 shadow-sm text-sm font-medium rounded-lg text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 transition-colors"
          >
            Cancel
          </.link>
          <.button
            type="submit"
            class="inline-flex items-center px-6 py-2 border border-transparent text-sm font-medium rounded-lg shadow-sm text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 transition-colors"
          >
            Save Task
          </.button>
        </div>
      </div>
    </.form>
    """
  end
end
