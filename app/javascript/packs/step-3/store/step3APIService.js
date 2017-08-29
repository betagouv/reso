import axios from 'axios'

export default {
    createContactForVisit(visitId, contact) {
        var config = {
            method: 'post',
            url: `/api/visits/${visitId}/contacts.json`,
            data: {
                contact: contact
            }
        }
        return this.send(config).then((response) => {
            return response.data
        })
    },

    updateVisitDate(visitId, dateString) {
        var config = {
            method: 'patch',
            url: `/api/visits/${visitId}.json`,
            data: {
                visit: {
                    happened_at: dateString
                }
            }
        }
        return this.send(config).then(() => {
            return true
        })
    },

    send(config) {
        return axios(config)
    }
}
