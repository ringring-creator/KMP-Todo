import Foundation
import ComposeApp
import SwiftUI

extension Todo {
    func toTodosItemUiState() -> TodosItemUiState {
        return TodosItemUiState(
            id: id?.int64Value,
            title: title,
            done: done,
            deadline: deadline.toString()
        )
    }
}

extension Kotlinx_datetimeLocalDate {
    func toString() -> String {
        return "\(year)-\(monthNumber)-\(dayOfMonth)"
    }
}

class TodosViewModel: ObservableObject {
    @Published var uiState = TodosUiState(todos: [])
    private let todoRepository:TodoRepository

    init(
        uiState: TodosUiState = TodosUiState(todos: []),
        todoRepository:TodoRepository = DataModules.Factory().createTodoRepository()
    ) {
        self.uiState = uiState
        self.todoRepository = todoRepository
    }
    
    func refresh() {
        Task {
            do {
                let todos = try await todoRepository.list()
                uiState = TodosUiState(
                    todos: todos.map { todo in
                        todo.toTodosItemUiState()
                    }
                )
            } catch {
                print("fail to todoRepository.list")
            }
        }
    }
}

struct TodosUiState {
    var todos: [TodosItemUiState]
}

struct TodosItemUiState: Identifiable {
    let id: Int64?
    let title: String
    var done: Bool
    let deadline: String
}

protocol TodosStateUpdater {
    func setDone(id: Int64, done: Bool)
}

struct TodosScreen: View {
    @ObservedObject var viewModel: TodosViewModel
    
    init(viewModel: TodosViewModel = TodosViewModel()) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        List(viewModel.uiState.todos) { todo in
            TodosItem(todo: todo)
        }
        .onAppear { self.viewModel.refresh() }
    }
}

struct TodosItem: View {
    @State var todo: TodosItemUiState

    
    var body: some View{
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 5) {
                Image(systemName: todo.done ? "checkmark.square" : "square")
                    .onTapGesture {
                        todo.done = !todo.done
                    }
                Text(todo.title)
            }
            HStack(spacing: 5) {
                Spacer()
                Image(systemName: "calendar")
                Text(todo.deadline)
            }
        }
        .onTapGesture {
            
        }
    }
}

struct TodosScreen_Previews: PreviewProvider {
    static var previews: some View {
        TodosScreen(
            viewModel: TodosViewModel(
                uiState:TodosUiState(
                    todos: [
                        TodosItemUiState(id: 1, title: "Todo 1", done: false, deadline: "2023-11-25"),
                        TodosItemUiState(id: 2, title: "Todo 2", done: true, deadline: "2023-11-26")
                    ]
                                    )
            )
        )
    }
}