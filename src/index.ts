import { NativeModules } from "react-native"

export type Options = {
    path: string
    stickers?: Array<string>
    animated: boolean
    photoQuality: number
}

export type ErrorCode =
    | "USER_CANCELLED"
    | "IMAGE_LOAD_FAILED"
    | "ACTIVITY_DOES_NOT_EXIST"
    | "FAILED_TO_SAVE_IMAGE"
    | "DONT_FIND_IMAGE"
    | "ERROR_UNKNOW"

const { PhotoEditor } = NativeModules

const defaultOptions: Options = {
    path: "",
    stickers: [],
    animated: true,
    photoQuality: 0.4,
}

const exportObject: PhotoEditorType = {
    open: (optionsEditor: Partial<Options>): Promise<string> => {
        const options = {
            ...defaultOptions,
            ...optionsEditor,
        }

        return new Promise(async (resolve, reject) => {
            try {
                const response = await PhotoEditor.open(options)
                if (response) {
                    resolve(response)
                }
            } catch (e) {
                reject(e)
            }
        })
    },
}

type PhotoEditorType = {
    open(option: Partial<Options>): Promise<string>
}

export default exportObject
